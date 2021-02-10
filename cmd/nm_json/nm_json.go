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
	"fmt"
	"log"
	"os"
)

var (
	nm      = flag.String("nm", "llvm-nm", `Which "nm" binary to use.`)
	archive = flag.String("archive", "", "Archive file to read.")
	typef   = flag.String("type", "", "Include only symbols of this type (empty means include everything).")
	output  = flag.String("output", "-", "Where to write the output file (- means stdout).")
	extern  = flag.Bool("extern_only", false, "List external symbols only.")
)

type flaglist []string

func (ls flaglist) String() string {
	if ls == nil {
		return ""
	}
	return fmt.Sprintf("%q", []string(ls))
}

func (ls *flaglist) Set(value string) error {
	*ls = append(*ls, value)
	return nil
}

func main() {
	externs := flaglist{}
	flag.Var(&externs, "externs", "Extern definition files.")
	flag.Parse()

	if *archive == "" {
		log.Fatal("missing required flag: -archive")
	}

	a, err := ParseArchive(*nm, *archive, *extern)
	if err != nil {
		log.Fatal(err)
	}

	t, err := a.SymbolTable(*typef)
	if err != nil {
		log.Fatal(err)
	}

	for _, ext := range externs {
		if err := t.ResolveExterns(ext); err != nil {
			log.Fatal(err)
		}
	}

	var out *os.File = os.Stdout
	if *output != "-" {
		f, err := os.Create(*output)
		if err != nil {
			log.Fatalf("error creating output file: %v", err)
		}
		out = f
	}

	if err := json.NewEncoder(out).Encode(t); err != nil {
		log.Fatal(err)
	}
}
