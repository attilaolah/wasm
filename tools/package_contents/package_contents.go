// Package main pre-processes NPM package contents.
package main

import (
	"flag"
	"fmt"
	"io"
	"io/fs"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

var (
	inputs  = flaglist{}
	outputs = flaglist{}
)

func init() {
	flag.Var(&inputs, "input", "Input files and directories.")
	flag.Var(&outputs, "output", "Output files, in the format `outfile=srcglob`.")
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
	mrg, err := remaps()
	if err != nil {
		log.Fatal(err)
	}

	// Map of WASM files.
	// These need to be renamed to update references.
	subs := map[string]string{}
	for dst, srcs := range mrg {
		if base, ok := strings.CutSuffix(dst, ".module.wasm"); ok {
			if len(srcs) != 1 {
				log.Fatalf("cannot merge wasm files: %q: %v", dst, srcs)
			}
			subs[strings.TrimSuffix(filepath.Base(srcs[0]), ".module.wasm")] = filepath.Base(base)
		}
	}

	for dst, srcs := range mrg {
		if err := mergeall(dst, srcs, subs); err != nil {
			log.Fatalf("failed creating %q: %v", dst, err)
		}
	}
}

func remaps() (map[string][]string, error) {
	paths := inpaths()
	result := map[string][]string{}
	for out, glob := range outglobs() {
		for _, path := range paths {
			_, fp := filepath.Split(path)
			m, err := filepath.Match(glob, fp)
			if err != nil {
				return nil, fmt.Errorf("bad pattern for %q: %q", out, glob)
			}
			if m {
				result[out] = append(result[out], path)
			}
		}
	}
	return result, nil
}

func inpaths() []string {
	paths := []string{}
	for _, input := range inputs {
		filepath.WalkDir(input, func(path string, info fs.DirEntry, err error) error {
			if !info.IsDir() {
				paths = append(paths, path)
			}
			return nil
		})
	}
	sort.Strings(paths)
	return paths
}

func outglobs() map[string]string {
	m := map[string]string{}
	for _, output := range outputs {
		out, glob, ok := strings.Cut(output, "=")
		if !ok { // No glob provided, match filenames directly.
			glob = out
		}
		m[out] = glob
	}
	return m
}

func mergeall(dst string, srcs []string, subs map[string]string) error {
	f, err := os.Create(dst)
	if err != nil {
		log.Fatalf("failed to create output %q: %v", dst, err)
	}
	defer f.Close()

	if strings.HasSuffix(dst, ".js") {
		// Make replacements in .js files.
		oldnew := []string{}
		for orig, repl := range subs {
			oldnew = append(oldnew, orig, repl)
		}
		repl := strings.NewReplacer(oldnew...)

		for _, src := range srcs {
			if err := merge2JS(f, repl, src); err != nil {
				log.Fatalf("failed to append to %q: %v", dst, err)
			}
		}
		return nil
	}

	for _, src := range srcs {
		if err := merge2(f, src); err != nil {
			log.Fatalf("failed to append to %q: %v", dst, err)
		}
	}

	return nil
}

func merge2(w io.Writer, path string) error {
	f, err := os.Open(path)
	if err != nil {
		return fmt.Errorf("failed to open %q: %w", path, err)
	}
	_, err = io.Copy(w, f)
	return err
}

func merge2JS(w io.Writer, r *strings.Replacer, path string) error {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return fmt.Errorf("failed to read %q: %w", path, err)
	}
	_, err = r.WriteString(w, string(b))
	return err
}
