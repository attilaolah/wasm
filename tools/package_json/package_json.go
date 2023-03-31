// Package main transforms package.json for exporting.
//
// The `package.json` file in the root of this repository contains dependencies
// used for configuring the Bazel workspace. However, the final `webnb` package
// has no direct dependencies since it is meant to be consumed as a single
// browser script.
//
// This binary produces the final `package.json`, to avoid duplicating it.
package main

import (
	"encoding/json"
	"flag"
	"log"
	"os"
	"path/filepath"

	// TODO: https://github.com/Rican7/conjson
	"github.com/Rican7/conjson"
	"github.com/Rican7/conjson/transform"
)

var (
	input  = flag.String("input", "-", "Where to read the input file from (- means stdin).")
	output = flag.String("output", "-", "Where to write the output file (- means stdout).")
)

type Package struct {
	Name, Description, Version, Homepage, License string

	Collaborators []string

	Module string

	// Intentionally dropped:
	// Repository, Bugs, Dependencies, DevDependencies, Types, SideEffects, Private
}

func main() {
	flag.Parse()

	var src *os.File = os.Stdin
	if *input != "-" {
		f, err := os.Open(*input)
		if err != nil {
			log.Fatalf("error opening input file: %v", err)
		}
		src = f
	}

	pkg := Package{}
	tr := transform.CamelCaseKeys(false)

	if err := conjson.NewDecoder(json.NewDecoder(src), tr).Decode(&pkg); err != nil {
		log.Fatalf("error parsing input file: %v", err)
	}

	var dst *os.File = os.Stdout
	if *output != "-" {
		// Make sure the directory exists.
		os.MkdirAll(filepath.Dir(*output), 0755)
		f, err := os.Create(*output)
		if err != nil {
			log.Fatalf("error creating output file: %v", err)
		}
		dst = f
	}

	enc := json.NewEncoder(dst)
	enc.SetIndent("", "  ")
	if err := conjson.NewEncoder(enc, tr).Encode(pkg); err != nil {
		log.Fatalf("error encoding output file: %v", err)
	}
}
