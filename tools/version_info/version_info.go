package version_info

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path"
	"regexp"
	"strings"

	"go.starlark.net/starlark"
	"golang.org/x/mod/semver"
)

var (
	// GRASS and others have a glued-on release candidate:
	rxPreRelease = regexp.MustCompile(`(v?\d+(?:\.\d+)*)(RC\d+)`)
	// OpenSSL version numbers: 1.2.3x -> 1.2.3+x
	// CMark-GFM version numbers: 0.29.0.gfm.3 -> 0.29.0+gfm.3
	rxBuild = regexp.MustCompile(`(v?\d+(?:\.\d+){2})\.?([0-9a-z.]+)`)
)

func fixPreRelease(v string) string {
	if m := rxPreRelease.FindAllStringSubmatch(v, 1); len(m) == 1 {
		v = m[0][1] + "-" + m[0][2]
	}
	return v
}

func fixBuild(v string) string {
	if m := rxBuild.FindAllStringSubmatch(v, 1); len(m) == 1 {
		v = m[0][1] + "+" + m[0][2]
	}
	return v
}

// Fake module stubs.
// We don't really want to load dependencies, but they have to return values they define.
var fakes = map[string]starlark.StringDict{
	"@bazel_tools//tools/build_defs/repo:http.bzl": {
		"http_archive": nil,
	},
}

// VersionInfo holds info about the version.
type VersionInfo struct {
	Name            string   `json:"name"`
	Version         string   `json:"version,omitempty"`
	UpstreamVersion string   `json:"upstream_version,omitempty"`
	URLs            []string `json:"urls,omitempty"`
	UpToDate        bool     `json:"up_to_date,omitempty"`
}

// GetVersion extracts the version from a single Starlark file.
func GetVersionInfo(p string) (*VersionInfo, error) {
	t := starlark.Thread{
		Load: func(t *starlark.Thread, module string) (starlark.StringDict, error) {
			if strings.HasPrefix(module, "@") {
				// We don't care much about external dependencies here.
				return fakes[module], nil
			}
			module = strings.Replace(module, ":", "/", 1)
			module = strings.TrimLeft(module, "//")
			return starlark.ExecFile(t, module, nil, starlark.Universe)
		},
	}
	globals, err := starlark.ExecFile(&t, p, nil, starlark.Universe)
	if err != nil {
		return nil, fmt.Errorf("failed to execute %q: %w", p, err)
	}
	v, ok := globals["VERSION"]
	if !ok {
		return nil, fmt.Errorf("VERSION not found in %q", p)
	}
	version := strings.Trim(v.String(), `"`)

	urls := []string{}
	if v, ok = globals["URLS"]; ok {
		list, ok := v.(*starlark.List)
		if !ok {
			return nil, fmt.Errorf("URLS is not a list in %q", p)
		}
		i := list.Iterate()
		var v starlark.Value
		for i.Next(&v) {
			urls = append(urls, strings.Trim(v.String(), `"`))
		}
		i.Done()
	} else {
		if v, ok = globals["URL"]; !ok {
			return nil, fmt.Errorf("URLS or URL not found in %q", p)
		}
		urls = append(urls, strings.Trim(v.String(), `"`))
	}

	info := &VersionInfo{
		Name:    path.Base(path.Dir(p)),
		Version: version,
		URLs:    urls,
	}
	info.Expand()
	return info, nil
}

// Expand replaces {versions} and friends in urls.
func (v *VersionInfo) Expand() {
	for i, url := range v.URLs {
		url = strings.ReplaceAll(url, "{name}", v.Name)
		url = strings.ReplaceAll(url, "{tname}", strings.Title(v.Name))
		url = strings.ReplaceAll(url, "{uname}", strings.ToUpper(v.Name))
		url = strings.ReplaceAll(url, "{version}", v.Version)
		url = strings.ReplaceAll(url, "{version-}", strings.ReplaceAll(v.Version, ".", "-"))
		url = strings.ReplaceAll(url, "{version_}", strings.ReplaceAll(v.Version, ".", "_"))
		url = strings.ReplaceAll(url, "{versionm}", strings.Split(v.Version, ".")[0])

		vmm := v.Version
		vmmx := v.Version
		if parts := strings.Split(v.Version, "."); len(parts) > 1 {
			vmm = strings.Join(parts[:2], ".")
			vmmx = strings.Join(parts[:2], "")
		}
		url = strings.ReplaceAll(url, "{versionmm}", vmm)
		url = strings.ReplaceAll(url, "{versionmmx}", vmmx)

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
		return fmt.Errorf("could not find any match for %q in %q", regex, url)
	}

	semantic := []string{}
	versions := map[string]string{}
	for _, match := range matches {
		if len(match) != 2 {
			return fmt.Errorf("wrong number of matches (expected 1): %v", match[1:])
		}
		v := string(match[1])

		sem := "v" + v
		sem = fixPreRelease(sem)
		sem = fixBuild(sem)
		if !semver.IsValid(sem) {
			return fmt.Errorf("could not parse as semantic version: %q (tried: %q)", v, sem)

		}
		semantic = append(semantic, sem)
		versions[sem] = v
	}
	if len(versions) == 0 {
		return fmt.Errorf("no version info found in %q for pattern %q", url, regex)
	}

	semver.Sort(semantic)
	v.UpstreamVersion = versions[semantic[len(semantic)-1]]
	v.UpToDate = v.Version == v.UpstreamVersion

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
