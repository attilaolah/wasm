package consistency

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"golang.org/x/mod/modfile"
	"gopkg.in/yaml.v3"
)

func TestGoConsistency(t *testing.T) {
	goMod, err := goVersionMod()
	if err != nil {
		t.Fatalf("could not parse go version from module config: %v", err)
	}

	goBzl, err := versionBzl("GO_VERSION")
	if err != nil {
		t.Fatalf("could not parse go version from workspace: %v", err)
	}

	goWfl, err := goVersionWorkflows()
	if err != nil {
		t.Fatalf("could not parse go version from workflow config: %v", err)
	}

	set := map[string]struct{}{}
	set[goMod] = struct{}{}
	set[goBzl] = struct{}{}
	set[goWfl] = struct{}{}

	if len(set) == 1 {
		return // All versions are in sync.
	}

	if strings.HasPrefix(goBzl, goMod+".") && goBzl == goWfl {
		// It is possible that a patch version is specified in the workspace rules.
		// In this case, the same patch version must be specified for the GitHub actions too.
		return
	}

	t.Errorf("multiple go versions detected: mod = %q, workspace = %q, workflows = %q", goMod, goBzl, goWfl)
}

func goVersionMod() (string, error) {
	data, err := os.ReadFile(filepath.Join(workspace, "go.mod"))
	if err != nil {
		return "", fmt.Errorf("failed to read go.mod: %w", err)
	}

	mod, err := modfile.Parse("go.mod", data, nil)
	if err != nil {
		return "", fmt.Errorf("failed to parse go.mod: %w", err)
	}
	if mod.Go == nil {
		return "", fmt.Errorf("go.mod does not contain version info")
	}
	return mod.Go.Version, nil
}

func goVersionWorkflows() (string, error) {
	glob, err := filepath.Glob(workflows)
	if err != nil {
		return "", err
	}

	version := ""
	for _, p := range glob {
		f, err := os.Open(p)
		if err != nil {
			return "", fmt.Errorf("failed to open file: %w", err)
		}
		defer f.Close()

		w := Workflow{}
		if err := yaml.NewDecoder(f).Decode(&w); err != nil {
			return "", fmt.Errorf("failed to decode file: %w", err)
		}

		for _, jobs := range w.Jobs {
			for _, step := range jobs.Steps {
				if setUpGo.MatchString(step.Uses) {
					if step.With.GoVersion != version && version != "" {
						return "", fmt.Errorf(
							"workflows contain different go-version configs: [%q, %q]",
							step.With.GoVersion, version)
					}
					version = step.With.GoVersion
				}
			}
		}
	}
	if version == "" {
		return "", fmt.Errorf("workflows do not contain go-version")
	}

	return version, nil
}
