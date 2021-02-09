// Package main implements a simple `nm` output parser.
// Currently only the `nm --format=sysv` format is supported, i.e. this:
//
//Symbols from build/libpng.a[png.o]:
//
//Name                  Value           Class        Type         Size             Line  Section
//
//adler32             |                |   U  |            NOTYPE|                |     |*UND*
//…
package main

import (
	"encoding/json"
	"flag"
	"log"
	"os"
)

var (
	archive = flag.String("archive", "", "Archive file to read.")
	output  = flag.String("output", "-", "Where to write the output file (- means stdout).")
)

func main() {
	flag.Parse()

	if *archive == "" {
		log.Fatal("missing required flag: -archive")
	}

	a, err := ParseArchive(*archive)
	if err != nil {
		log.Fatal(err)
	}

	var out *os.File = os.Stdout
	if *output != "-" {
		f, err := os.Create(*output)
		if err != nil {
			log.Fatalf("error creating output file: %v", err)
		}
		out = f
	}

	if err := json.NewEncoder(out).Encode(a); err != nil {
		log.Fatal(err)
	}
}
