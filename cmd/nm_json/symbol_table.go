// Package main implements a simple `nm` output parser.
package main

import (
	"fmt"
	"sort"
	"strings"
	"unicode"
)

const (
	UndefClass Class = 'U'

	UndefType = "NOTYPE"
	TLSType   = "TLS"

	UndefSection = "*UND*"
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
	Objects []string `json:"objects"`
	Symbol
}

// SymbolTable normalises an archive into defined and external symbols.
func (a *Archive) SymbolTable(typef string) (*SymbolTable, error) {
	t := SymbolTable{}
	defm := map[string][]string{}
	undefs := []string{}

	for _, o := range a.Objects {
		for _, s := range o.Symbols {
			if s.Class != UndefClass {
				defm[s.Name] = append(defm[s.Name], o.Name)
				if s.Type == typef || typef == "" {
					t.Symbols = append(t.Symbols, SymbolDef{
						Symbol: *s,
					})
				}
				continue
			}
			if s.Type != UndefType && s.Type != TLSType {
				return nil, fmt.Errorf("undefinod symbol %q has unexpected type: %q", s.Name, s.Type)
			}
			if s.Section != UndefSection {
				return nil, fmt.Errorf("undefinod symbol %q found in unexpected section: %q", s.Name, s.Type)
			}
			undefs = append(undefs, s.Name)
		}
	}

	for i := range t.Symbols {
		p := &t.Symbols[i]
		p.Objects = defm[p.Name]
		// Clear size, value & line.
		// These can be different depending on where the symbol is defined.
		p.Value = nil
		p.Size = nil
		p.Line = ""
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
