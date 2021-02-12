// Package main implements a simple `nm` output parser.
package main

import (
	"encoding/json"
	"fmt"
	"sort"
	"strings"
	"unicode"
)

const (
	UndefClass   Class = 'U'
	UndefSection       = "*UND*"
)

// SymbolTable groups symbols in an archive.
type SymbolTable struct {
	Name    string     `json:"name"`
	Symbols SymbolDefs `json:"symbols,omitempty"`
	Externs ExternDefs `json:"externs,omitempty"`
	Undefs  []string   `json:"undefs,omitempty"`
}

// SymbolDefs is a sortable slice of SymbolDef objects.
type SymbolDefs []SymbolDef

// SymbolDef represents a unique symbol definition in an archive.
type SymbolDef jSymbolDef

// Like SymbolDef, but without the custom JSON decoder.
type jSymbolDef struct {
	Objects []string `json:"objects"`
	Symbol
}

// ExternDefs is a sortable slice of ExternDef objects.
type ExternDefs []ExternDef

// ExternDef represents a symbol resolved to an external archive.
type ExternDef struct {
	Archive string   `json:"archive"`
	Symbols []string `json:"symbols"`
}

// SymbolTable normalises an archive into defined and external symbols.
func (a *Archive) SymbolTable(typef string) (*SymbolTable, error) {
	t := SymbolTable{Name: a.Name}
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
			if s.Section != UndefSection && s.Section != "" {
				return nil, fmt.Errorf("undefinod symbol %q found in unexpected section: %q", s.Name, s.Type)
			}
			undefs = append(undefs, s.Name)
		}
	}

	for i := range t.Symbols {
		p := &t.Symbols[i]
		// TODO: de-duplicate!
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
		t.Undefs = append(t.Undefs, name)
		undefm[name] = struct{}{}
	}

	sort.Sort(t.Symbols)
	sort.Strings(t.Undefs)

	return &t, nil
}

// Len, Less and Swap implement sort.Interface.
func (sd SymbolDefs) Len() int           { return len(sd) }
func (sd SymbolDefs) Less(i, j int) bool { return strings.Compare(sd[i].Name, sd[j].Name) < 0 }
func (sd SymbolDefs) Swap(i, j int)      { sd[i], sd[j] = sd[j], sd[i] }

// UnmarshalJSON implements the json.Unmarshaler interface.
func (sd *SymbolDef) UnmarshalJSON(data []byte) error {
	j := jSymbolDef{}
	if err := json.Unmarshal(data, &j); err != nil {
		s := "" // just the name
		if json.Unmarshal(data, &s) != nil {
			return err // keep outer error
		}
		sd.Name = s
		return nil
	}
	*sd = SymbolDef(j)
	return nil
}

func (s *Symbol) Extern() bool {
	return unicode.IsUpper(rune(s.Class))
}
