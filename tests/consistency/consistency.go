package consistency

import (
	"fmt"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"strings"

	"go.starlark.net/starlark"
)

var (
	setUpGo = regexp.MustCompile(`^actions/setup-go(@v\d+)?$`)

	workspace = filepath.Join(os.Getenv("TEST_SRCDIR"), os.Getenv("TEST_WORKSPACE"))
	workflows = filepath.Join(workspace, "tests/consistency/workflows/*.yml")
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

func versionBzl(key string) (string, error) {
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
	v, ok := globals[key]
	if !ok {
		return "", fmt.Errorf("%q: %q not found", path.Base(p), key)
	}
	return strings.Trim(v.String(), `"`), nil
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
