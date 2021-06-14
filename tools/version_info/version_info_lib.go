package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strings"

	"go.starlark.net/starlark"
)

// Module stubs.
// We don't really want to load dependencies, but they have to return values they define.
var modules = map[string]starlark.StringDict{
	"//:http_archive.bzl": {
		"http_archive": nil,
	},
	"//toolchains/make:configure.bzl": {
		"patch_files": nil,
	},
}

// VersionInfo holds info about the version.
type VersionInfo struct {
	Version         string   `json:"version,omitempty"`
	UpstreamVersion string   `json:"upstream_version,omitempty"`
	URLs            []string `json:"urls,omitempty"`
}

// GetVersion extracts the version from a single Starlark file.
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
		Version: version,
		URLs:    urls,
	}
	info.Expand()
	return info, nil
}

// Expand replaces {versions} and friends in urls.
func (v *VersionInfo) Expand() {
	for i, url := range v.URLs {
		url = strings.ReplaceAll(url, "{version}", v.Version)
		url = strings.ReplaceAll(url, "{version-}", strings.ReplaceAll(v.Version, ".", "-"))
		url = strings.ReplaceAll(url, "{version_}", strings.ReplaceAll(v.Version, ".", "_"))
		url = strings.ReplaceAll(url, "{versionm}", strings.Split(v.Version, ".")[0])

		vmm := v.Version
		if parts := strings.Split(v.Version, "."); len(parts) > 1 {
			vmm = strings.Join(parts[:2], ".")
		}
		url = strings.ReplaceAll(url, "{versionmm}", vmm)

		v.URLs[i] = url
	}
}

func (v *VersionInfo) GetUpstreamVersion(url, regex string) error {
	rx, err := regexp.Compile(regex)
	if err != nil {
		return fmt.Errorf("failed to compile regular expression %q: %w", regex, err)
	}

	res, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("failed to download %q: %w", url, err)
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %w", err)
	}

	matches := rx.FindAllSubmatch(body, -1)
	if len(matches) == 0 {
		fmt.Println(string(body))
		return fmt.Errorf("could not find any match for %q in %q", regex, url)
	}

	for _, match := range matches {
		if len(match) != 2 {
			return fmt.Errorf("wrong number of matches (expected 1): %v", match[1:])
		}

		// TODO: Implement semantic-version based sorting.
		v.UpstreamVersion = string(match[1])
		break
	}

	return nil
}

func (v *VersionInfo) WriteTo(path string) error {
	var out *os.File = os.Stdout
	if path != "-" {
		f, err := os.Create(path)
		if err != nil {
			return fmt.Errorf("failed to create output file: %w", err)
		}
		out = f
	}

	if err := json.NewEncoder(out).Encode(v); err != nil {
		return fmt.Errorf("failed to encode version info: %w", err)
	}

	return nil
}
