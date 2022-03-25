package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"text/template"

	"github.com/attilaolah/wasm/tools/version_info"
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
		b.WriteString(v.Version)
		for _, u := range v.URLs {
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
func GetVersionInfos(pattern string) (map[string]version_info.VersionInfo, error) {
	vers := map[string]version_info.VersionInfo{}
	matches, err := filepath.Glob(pattern)
	if err != nil {
		return nil, fmt.Errorf("failed to expand %q: %w", pattern, err)
	}

	for _, path := range matches {
		v, err := version_info.GetVersionInfo(path)
		if err != nil {
			return nil, fmt.Errorf("error extracting versions: %w", err)
		}
		vers[path] = *v
	}
	return vers, nil
}

func label(path string) string {
	dir, _ := filepath.Split(path)
	return "//" + strings.Trim(dir, "/")
}

func url(path string) string {
	dir, _ := filepath.Split(path)
	return fmt.Sprintf("https://github.com/attilaolah/wasm/blob/main/%s/BUILD.bazel", strings.Trim(dir, "/"))
}
