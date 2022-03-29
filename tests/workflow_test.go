package main

import (
	"fmt"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"go.starlark.net/starlark"
	"golang.org/x/mod/modfile"
	"gopkg.in/yaml.v3"
)

var (
	setUpGo = regexp.MustCompile(`^actions/setup-go(@v\d+)?$`)

	workspace = filepath.Join(os.Getenv("TEST_SRCDIR"), os.Getenv("TEST_WORKSPACE"))
)

type Workflow struct {
	Name string
	Jobs map[string]Job
}

type Job struct {
	RunsOn string `yaml:"runs-on"`
	Steps  []struct {
		Uses string
		With struct {
			GoVersion string `yaml:"go-version"`
		}
	}
}

func TestGoVersionConsistency(t *testing.T) {
	goMod, err := goVersionMod()
	if err != nil {
		t.Fatalf("could not parse go version from module config: %v", err)
	}

	goBzl, err := goVersionBzl()
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

	if len(set) != 1 {
		t.Errorf("multiple go versions detected: mod = %q, workspace = %q, workflows = %q", goMod, goBzl, goWfl)
	}
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

func goVersionBzl() (string, error) {
	p := filepath.Join(workspace, "versions.bzl")
	t := starlark.Thread{
		Load: func(t *starlark.Thread, module string) (starlark.StringDict, error) {
			return nil, nil
		},
	}
	globals, err := starlark.ExecFile(&t, p, nil, starlark.Universe)
	if err != nil {
		return "", fmt.Errorf("failed to execute %q: %w", p, err)
	}
	key := "GO_VERSION"
	v, ok := globals[key]
	if !ok {
		return "", fmt.Errorf("%q: %q not found", path.Base(p), key)
	}
	return strings.Trim(v.String(), `"`), nil
}

func goVersionWorkflows() (string, error) {
	glob, err := filepath.Glob(filepath.Join(workspace, "tests/workflows/*.yml"))
	if err != nil {
		return "", err
	}

	version := ""
	for _, p := range glob {
		f, err := os.Open(p)
		if err != nil {
			return "", fmt.Errorf("failed to open file: %w", err)
		}

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

func mapKeys(m map[string]Job) []string {
	keys := make([]string, len(m))

	i := 0
	for k := range m {
		keys[i] = k
		i++
	}
	return keys
}
