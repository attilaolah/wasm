// Package main implements a simple `nm` output parser.
package main

import (
	"fmt"
	"sort"
)

const (
	UndefClass   Class = 'U'
	UndefType          = "NOTYPE"
	UndefSection       = "*UND*"
)

// SymbolTable groups symbols in an archive.
type SymbolTable struct {
	Defined []SymbolDef `json:"symbols,omitempty"`
	Externs []string    `json:"externs,omitempty"`
}

// SymbolDef represents a unique symbol definition in an archive.
type SymbolDef struct {
	Object string `json:"object,omitempty"`
	Symbol
}

// SymbolTable normalises an archive into defined and external symbols.
func (a *Archive) SymbolTable() (*SymbolTable, error) {
	t := SymbolTable{}
	defm := map[string]string{}
	undefs := []string{}

	for _, o := range a.Objects {
		for _, s := range o.Symbols {
			if s.Class != UndefClass {
				t.Defined = append(t.Defined, SymbolDef{
					Object: o.Name,
					Symbol: *s,
				})
				// TODO: Check for duplicate symbol defs!
				if ex, ok := defm[s.Name]; ok {
					return nil, fmt.Errorf("symbol %q redefined in %q; previous definition in %q", s.Name, o.Name, ex)
				}
				defm[s.Name] = o.Name
				continue
			}
			if s.Type != UndefType {
				return nil, fmt.Errorf("undefinod symbol %q has unexpected type: %q", s.Name, s.Type)
			}
			if s.Section != UndefSection {
				return nil, fmt.Errorf("undefinod symbol %q has unexpected type: %q", s.Name, s.Type)
			}
			undefs = append(undefs, s.Name)
		}
	}

	sort.Strings(undefs)

	undefm := map[string]struct{}{}
	for _, name := range undefs {
		if _, ok := defm[name]; ok {
			continue // defined elsewhere
		}
		if _, ok := undefm[name]; ok {
			continue // already added to the table
		}
		t.Externs = append(t.Externs, name)
		undefm[name] = struct{}{}
	}

	return &t, nil
}
