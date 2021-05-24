package main

import (
	"flag"
	"fmt"
	"os"
)

var (
	vURL   = flag.String("version_url", "", "HTTP(S) link containing upstream version info.")
	vRegex = flag.String("version_regex", "", "Regular expression that should match the upstream version(s).")
	bzl    = flag.String("package_bzl", "", "Starlark package.bzl file containing version info.")
	output = flag.String("output", "-", "Where to write the output file (- means stdout).")
)

func main() {
	flag.Parse()

	info, err := GetVersionInfo(*bzl)
	if err != nil {
		fmt.Printf("error parsing local version info: %v\n", err)
		os.Exit(1)

	}
	if err := info.GetUpstreamVersion(*vURL, *vRegex); err != nil {
		fmt.Printf("error getting upstream version: %v\n", err)
		os.Exit(1)
	}

	if err := info.WriteTo(*output); err != nil {
		fmt.Printf("error writing version info to %q: %v\n", *output, err)
		os.Exit(1)
	}
}
