// Package main implements a simple `nm` output parser.
package main

import (
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"strings"
)

func (t *SymbolTable) ResolveExterns(path string) error {
	f, err := os.Open(path)
	if err != nil {
		return fmt.Errorf("error opening external symbols file %q: %w", path, err)
	}
	defer f.Close()

	ext := SymbolTable{}
	if err := json.NewDecoder(f).Decode(&ext); err != nil {
		return fmt.Errorf("error parsing external symbols from %q: %w", path, err)
	}

	symbols := map[string]struct{}{}
	for _, s := range ext.Symbols {
		// TODO: Check for conflicts!
		symbols[s.Name] = struct{}{}
	}

	var undefs []string
	def := ExternDef{Archive: ext.Name}
	for _, u := range t.Undefs {
		if _, ok := symbols[u]; ok {
			def.Symbols = append(def.Symbols, u)
		} else {
			undefs = append(undefs, u)
		}
	}
	if len(def.Symbols) != 0 {
		t.Externs = append(t.Externs, def)
		sort.Sort(t.Externs)
		t.Undefs = undefs
	}

	return nil
}

// Len, Less and Swap implement sort.Interface.
func (ed ExternDefs) Len() int           { return len(ed) }
func (ed ExternDefs) Less(i, j int) bool { return strings.Compare(ed[i].Archive, ed[j].Archive) < 0 }
func (ed ExternDefs) Swap(i, j int)      { ed[i], ed[j] = ed[j], ed[i] }
