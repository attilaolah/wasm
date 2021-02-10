// Package main implements a simple `nm` output parser.
package main

import (
	"fmt"
	"sort"
	"strings"
	"unicode"
)

const (
	UndefClass   Class = 'U'
	UndefType          = "NOTYPE"
	UndefSection       = "*UND*"
)

// SymbolTable groups symbols in an archive.
type SymbolTable struct {
	Symbols SymbolDefs `json:"symbols,omitempty"`
	Externs []string   `json:"externs,omitempty"`
}

// SymbolDefs is a sortable slice of SymbolDef objects.
type SymbolDefs []SymbolDef

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
				t.Symbols = append(t.Symbols, SymbolDef{
					Object: o.Name,
					Symbol: *s,
				})
				if ex, ok := defm[s.Name]; ok {
					if s.Extern() {
						// Externs should not be redefined!
						return nil, fmt.Errorf("external symbol %q redefined in %q; previous definition in %q", s.Name, o.Name, ex)
					}
					// But locals can be redefined.
					continue
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

	sort.Sort(t.Symbols)
	sort.Strings(t.Externs)

	return &t, nil
}

// Len, Less and Swap implement sort.Interface.
func (sd SymbolDefs) Len() int           { return len(sd) }
func (sd SymbolDefs) Less(i, j int) bool { return strings.Compare(sd[i].Name, sd[j].Name) < 0 }
func (sd SymbolDefs) Swap(i, j int)      { sd[i], sd[j] = sd[j], sd[i] }

func (s *Symbol) Extern() bool {
	return unicode.IsUpper(rune(s.Class))
}
