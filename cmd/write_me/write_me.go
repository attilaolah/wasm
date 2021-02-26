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

// Location of the template file.
const tpl = "cmd/write_me/write_me.tpl"

var (
	output = flag.String("output",
		func() string {
			workspace := os.Getenv("BUILD_WORKSPACE_DIRECTORY")
			if workspace != "" {
				return filepath.Join(workspace, "README.md")
			}
			return "-"
		}(),
		"Where to write the output file (- means stdout).")

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

	root := os.Getenv("BUILD_WORKSPACE_DIRECTORY")
	if root == "" {
		fmt.Println("BUILD_WORKSPACE_DIRECTORY not set!")
		fmt.Println("Run this command using Bazel, i.e. like this: bazel run //cmd/write_me")
		os.Exit(1)
	}

	os.Chdir(root)
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

	var out *os.File = os.Stdout
	if *output != "-" {
		f, err := os.Create(*output)
		if err != nil {
			fmt.Printf("error creating output file: %v\n", err)
			os.Exit(1)
		}
		out = f
	}

	if err := t.Execute(out, template.FuncMap{
		"Libraries": lib,
		"Tools":     tools,
	}); err != nil {
		fmt.Printf("error executing template %q: %v\n", tpl, err)
		os.Exit(1)
	}
}

// VersionInfo holds info about the version.
type VersionInfo struct {
	version string
	urls    []string
}

// Expand replaces {versions} and friends in urls.
func (v *VersionInfo) Expand() {
	for i, url := range v.urls {
		url = strings.ReplaceAll(url, "{version}", v.version)
		url = strings.ReplaceAll(url, "{version-}", strings.ReplaceAll(v.version, ".", "-"))
		url = strings.ReplaceAll(url, "{version_}", strings.ReplaceAll(v.version, ".", "_"))
		url = strings.ReplaceAll(url, "{versionm}", strings.Split(v.version, ".")[0])

		vmm := v.version
		if parts := strings.Split(v.version, "."); len(parts) > 1 {
			vmm = strings.Join(parts[:2], ".")
		}
		url = strings.ReplaceAll(url, "{versionmm}", vmm)

		v.urls[i] = url
	}
}

// MDTable generates a Markdown version table.
func MDTable(prefix string) (string, error) {
	vers, err := GetVersionInfos(prefix + "/*/package.bzl")
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
		v := vers[path]
		b.WriteString("[`")
		b.WriteString(label(path))
		b.WriteString("`](")
		b.WriteString(url(path))
		b.WriteString(") | ")
		b.WriteString(v.version)
		for _, u := range v.urls {
			b.WriteString(" [🔗](")
			b.WriteString(u)
			b.WriteString(")")
		}
		b.WriteString("\n")
	}

	return b.String(), nil
}

// GetVersionInfos extracts the version info from all matching files.
// Keys in the returned maps are Starlark file names matching under root/.
func GetVersionInfos(pattern string) (map[string]VersionInfo, error) {
	vers := map[string]VersionInfo{}
	matches, err := filepath.Glob(pattern)
	if err != nil {
		return nil, fmt.Errorf("failed to expand %q: %w", pattern, err)
	}

	for _, path := range matches {
		v, err := GetVersionInfo(path)
		if err != nil {
			return nil, fmt.Errorf("error extracting versions: %w", err)
		}
		vers[path] = *v
	}
	return vers, nil
}

// GetVersion extracts the version from a single file.
func GetVersionInfo(path string) (*VersionInfo, error) {
	t := starlark.Thread{
		Load: func(t *starlark.Thread, module string) (starlark.StringDict, error) {
			return modules[module], nil
		},
	}
	globals, err := starlark.ExecFile(&t, path, nil, starlark.Universe)
	if err != nil {
		return nil, fmt.Errorf("failed to execute %q: %w", path, err)
	}
	v, ok := globals["VERSION"]
	if !ok {
		return nil, fmt.Errorf("VERSION not found in %q", path)
	}
	version := strings.Trim(v.String(), `"`)

	urls := []string{}
	if v, ok = globals["URLS"]; ok {
		list, ok := v.(*starlark.List)
		if !ok {
			return nil, fmt.Errorf("URLS is not a list in %q", path)
		}
		i := list.Iterate()
		var v starlark.Value
		for i.Next(&v) {
			urls = append(urls, strings.Trim(v.String(), `"`))
		}
		i.Done()
	} else {
		if v, ok = globals["URL"]; !ok {
			return nil, fmt.Errorf("URLS or URL not found in %q", path)
		}
		urls = append(urls, strings.Trim(v.String(), `"`))
	}

	info := &VersionInfo{
		version: version,
		urls:    urls,
	}
	info.Expand()
	return info, nil
}

func label(path string) string {
	dir, _ := filepath.Split(path)
	return "//" + strings.Trim(dir, "/")
}

func url(path string) string {
	dir, _ := filepath.Split(path)
	return fmt.Sprintf("https://github.com/attilaolah/wasm/blob/main/%s/BUILD.bazel", strings.Trim(dir, "/"))
}
