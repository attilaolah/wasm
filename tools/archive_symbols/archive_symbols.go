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
	"path/filepath"
	"strings"
)

var (
	nm       = flag.String("nm", "llvm-nm", `Which "nm" binary to use.`)
	typef    = flag.String("type", "", "Include only symbols of this type (empty means include everything).")
	output   = flag.String("output", "{archive}.json", "Where to write the output file (- means stdout).")
	extern   = flag.Bool("extern_only", false, "List external symbols only.")
	strict   = flag.Bool("strict", true, "Strict mode: fail if there are any undefined symbols.")
	archives = flaglist{}
	externs  = flaglist{}
)

func init() {
	flag.Var(&archives, "archive", "Archive files to read. Repeat for multiple archive files.")
	flag.Var(&externs, "externs", "Extern definition files. Repeat for multiple extern files.")
	flag.Parse()
}

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
	if len(archives) == 0 {
		log.Fatal("missing required flag: -archive")
	}

	al, err := ParseArchives(*nm, archives, *extern)
	if err != nil {
		log.Fatal(err)
	}

	stl := []*SymbolTable{}
	for _, a := range al {
		t, err := a.SymbolTable(*typef)
		if err != nil {
			log.Fatal(err)
		}
		stl = append(stl, t)
	}

	for _, t := range stl {
		for _, ext := range stl {
			if ext != t {
				t.ResolveSymbols(ext)
			}
		}
	}

	for _, t := range stl {
		for _, ext := range externs {
			if err := t.ResolveExterns(ext); err != nil {
				log.Fatal(err)
			}
		}
	}

	undefs := 0
	if *strict {
		for _, t := range stl {
			if len(t.Undefs) != 0 {
				log.Printf("undefined symbols in %q:", t.Name)
				if err := json.NewEncoder(os.Stderr).Encode(t.Undefs); err != nil {
					log.Fatal(err)
				}
				undefs++
			}
		}
		if undefs > 0 {
			log.Fatalf("%d archive(s) contain undefined symbols", undefs)
		}
	}

	for _, t := range stl {
		var out *os.File = os.Stdout
		if *output != "-" {
			name := strings.TrimSuffix(t.Name, filepath.Ext(t.Name))
			name = strings.ReplaceAll(*output, "{archive}", name)
			os.MkdirAll(filepath.Dir(name), 0755) // make sure the directory exists
			f, err := os.Create(name)
			if err != nil {
				log.Fatalf("error creating output file: %v", err)
			}
			out = f
		}

		if err := json.NewEncoder(out).Encode(t); err != nil {
			log.Fatal(err)
		}
	}
}
