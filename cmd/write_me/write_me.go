package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"text/template"

	"go.starlark.net/starlark"
)

const (
	// Name of the constant holding the version number.
	ver = "VERSION"

	// Location of the template file.
	tpl = "cmd/write_me/write_me.tpl"
)

var (
	root = flag.String("root", "", "Repo root directory.")

	// Module stubs.
	// We don't really want to load dependencies, but they have to return values they define.
	modules = map[string]starlark.StringDict{
		"//:http_archive.bzl": {
			"http_archive": nil,
		},
		"//tools/emscripten:emconfigure.bzl": {
			"EMCONFIGURE": nil,
		},
	}
)

func main() {
	flag.Parse()
	if *root == "" {
		fmt.Println("missing required flag: -root")
		os.Exit(1)
	}

	os.Chdir(*root)
	t, err := template.ParseFiles(tpl)
	if err != nil {
		fmt.Printf("error loading template %q: %v\n", tpl, err)
		os.Exit(1)
	}

	lib, err := MDTable("lib")
	if err != nil {
		fmt.Printf("error generating lib version table: %v\n", err)
		os.Exit(1)
	}
	tools, err := MDTable("tools")
	if err != nil {
		fmt.Printf("error generating tools version table: %v\n", err)
		os.Exit(1)
	}

	if err := t.Execute(os.Stdout, template.FuncMap{
		"Libraries": lib,
		"Tools":     tools,
	}); err != nil {
		fmt.Printf("error executing template %q: %v\n", tpl, err)
		os.Exit(1)
	}
}

// MDTable generates a Markdown version table.
func MDTable(prefix string) (string, error) {
	vers, err := GetVersions(prefix + "/*/package.bzl")
	if err != nil {
		return "", err
	}

	i := 0
	paths := make([]string, len(vers))
	for path := range vers {
		paths[i] = path
		i++
	}
	sort.Strings(paths)

	var b strings.Builder
	for _, path := range paths {
		b.WriteString("`")
		b.WriteString(label(path))
		b.WriteString("` | ")
		b.WriteString(vers[path])
		b.WriteString("\n")
	}

	return b.String(), nil
}

// GetVersions extracts the version info from all matching files.
// Keys in the returned maps are Starlark file names matching under root/.
func GetVersions(pattern string) (map[string]string, error) {
	vers := map[string]string{}
	matches, err := filepath.Glob(pattern)
	if err != nil {
		return nil, fmt.Errorf("failed to expand %q: %w", pattern, err)
	}

	for _, path := range matches {
		v, err := GetVersion(path)
		if err != nil {
			return nil, fmt.Errorf("error extracting versions: %w", err)
		}
		vers[path] = v
	}
	return vers, nil
}

// GetVersion extracts the version from a single file.
func GetVersion(path string) (string, error) {
	t := starlark.Thread{
		Load: func(t *starlark.Thread, module string) (starlark.StringDict, error) {
			return modules[module], nil
		},
	}
	globals, err := starlark.ExecFile(&t, path, nil, starlark.Universe)
	if err != nil {
		return "", fmt.Errorf("failed to execute %q: %w", path, err)
	}
	v, ok := globals[ver]
	if !ok {
		return "", fmt.Errorf("VERSION not found in %q", path)
	}

	return strings.Trim(v.String(), `"`), nil
}

func label(path string) string {
	dir, _ := filepath.Split(path)
	return "//" + strings.Trim(dir, "/")
}
