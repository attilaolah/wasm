package consistency

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/moby/buildkit/frontend/dockerfile/command"
	"github.com/moby/buildkit/frontend/dockerfile/parser"
	"gopkg.in/yaml.v3"
)

func TestOsConsistency(t *testing.T) {
	osDocker, err := osVersionDocker()
	if err != nil {
		t.Fatalf("could not parse os version from docker file: %v", err)
	}

	osBzl, err := versionBzl("OS_VERSION")
	if err != nil {
		t.Fatalf("could not parse os version from workspace: %v", err)
	}

	osWfl, err := osVersionWorkflows()
	if err != nil {
		t.Fatalf("could not parse os version from workflow config: %v", err)
	}

	set := map[string]struct{}{}
	set[osDocker] = struct{}{}
	set[osBzl] = struct{}{}
	set[osWfl] = struct{}{}

	if len(set) != 1 {
		t.Errorf("multiple os versions detected: docker = %q, workspace = %q, workflows = %q", osDocker, osBzl, osWfl)
	}
}

func osVersionDocker() (string, error) {
	f, err := os.Open(filepath.Join(workspace, "docker", "Dockerfile"))
	if err != nil {
		return "", fmt.Errorf("failed to open file: %w", err)
	}
	defer f.Close()

	d, err := parser.Parse(f)
	if err != nil {
		return "", fmt.Errorf("failed to parse docker file: %w", err)
	}

	for _, n := range d.AST.Children {
		if strings.ToLower(n.Value) != command.From {
			continue
		}
		f := strings.Fields(n.Original)
		if len(f) != 2 {
			return "", fmt.Errorf("malformed from command in docker file: %q", n.Original)
		}
		return strings.Replace(f[1], ":", "-", 1), nil
	}

	return "", errors.New("no from command found in docker file")
}

func osVersionBzl() (string, error) {
	return "TODO", nil
}

func osVersionWorkflows() (string, error) {
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
			if jobs.RunsOn != version && version != "" {
				return "", fmt.Errorf(
					"workflows contain different runs-on configs: [%q, %q]",
					jobs.RunsOn, version)
			}
			version = jobs.RunsOn
		}
	}
	if version == "" {
		return "", fmt.Errorf("workflows do not contain runs-on")
	}

	return version, nil
}
