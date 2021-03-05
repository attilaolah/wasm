// Package main implements a simple `nm` output parser.
package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
)

// Archives is a sortable slice of Archive objects.
type Archives []*Archive

// Archive is a collection of objects archived under a single name, e.g. "libpng.a".
type Archive struct {
	Name    string    `json:"name"`
	Objects []*Object `json:"objects,omitempty"`
}

// Object is a list of symbols grouped in a single name, e.g. "png.o".
type Object struct {
	Name    string    `json:"name"`
	Symbols []*Symbol `json:"symbols,omitempty"`
}

// Symbol is a single symbol in the archived object.
type Symbol struct {
	Name    string  `json:"name"`
	Value   *uint64 `json:"value,omitempty"`
	Class   Class   `json:"class,omitempty"`
	Type    string  `json:"type,omitempty"`
	Size    *uint64 `json:"size,omitempty"`
	Line    string  `json:"line,omitempty"`
	Section string  `json:"section,omitempty"`
}

// Class is the class column returned by `nm --format=sysv`.
type Class byte

// ParseArchive executes `nm` on a single archive.
func ParseArchives(nm string, paths []string, extern bool) (Archives, error) {
	args := []string{
		"--format=sysv",
		"--print-file-name",
		"--print-size",
		"--demangle",
		"--no-sort",
	}
	if extern {
		args = append(args, "--extern-only")
	}
	cmd := exec.Command(nm, append(args, paths...)...)

	out, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("error running command %q: %w; output: %s", cmd, err, out)
	}

	return Parse(bytes.NewBuffer(out))
}

// Parse parses `nm --format=sysv` output.
func Parse(src io.Reader) (Archives, error) {
	o := &Object{}
	am := map[string]*Archive{}

	ln := 0
	scanner := bufio.NewScanner(src)
	for scanner.Scan() {
		line := scanner.Text()
		ln++

		if strings.HasSuffix(line, ": no symbols") {
			continue
		}

		parts := strings.Split(line, "|")
		if l := len(parts); l < 7 {
			return nil, fmt.Errorf("line %d: %q: row contains %d columns instead of 7", ln, line, l)
		} else if l > 7 {
			// Symbol contains a literal "|", e.g. "operator|=".
			s := strings.Join(parts[:len(parts)-7], "|")
			parts = append([]string{s}, parts[len(parts)-6:]...)
			if len(parts) != 7 {
				panic(parts)
			}
		}
		subparts := strings.SplitN(parts[0], ": ", 2)
		if len(subparts) != 2 {
			return nil, fmt.Errorf("line %d: %q: failed to parse %q as `archive:object: symbol`", ln, line, strings.TrimSpace(parts[0]))
		}
		ao := strings.SplitN(subparts[0], ":", 2)
		if len(ao) == 1 {
			// The archive name is missing for some reason.
			ao = []string{"", ao[0]}
		}
		_, aname := filepath.Split(ao[0])
		a, ok := am[aname]
		if !ok {
			a = &Archive{Name: aname}
			am[aname] = a
		}
		if o.Name != ao[1] {
			o = &Object{Name: ao[1]}
			a.Objects = append(a.Objects, o)
		}

		s := Symbol{
			Name:    strings.TrimSpace(subparts[1]),
			Type:    strings.TrimSpace(parts[3]),
			Line:    strings.TrimSpace(parts[5]),
			Section: strings.TrimSpace(parts[6]),
		}
		if v := strings.TrimSpace(parts[2]); len(v) == 1 {
			s.Class = Class(v[0])
		} else if len(v) > 1 {
			return nil, fmt.Errorf("line %d: %q: unknown class: %q", ln, line, v)
		}
		if v := strings.TrimSpace(parts[1]); v != "" {
			u, err := strconv.ParseUint(v, 16, 64)
			if err != nil {
				return nil, fmt.Errorf("line %d: %q: failed to parse value (%q) as hex: %w", ln, line, v, err)
			}
			s.Value = &u
		}
		if v := strings.TrimSpace(parts[4]); v != "" {
			u, err := strconv.ParseUint(v, 16, 64)
			if err != nil {
				return nil, fmt.Errorf("line %d: %q: failed to parse size (%q) as hex: %w", ln, line, v, err)
			}
			s.Size = &u
		}

		if !s.BuiltIn() {
			o.Symbols = append(o.Symbols, &s)
		}
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("failed to scan line: %w", err)
	}

	al := Archives{}
	for _, a := range am {
		al = append(al, a)
	}
	sort.Sort(&al)

	return al, nil
}

func (s Symbol) BuiltIn() bool {
	// Match is_builtin_name() from gcc/builtins.c:
	if strings.HasPrefix(s.Name, "__builtin_") ||
		strings.HasPrefix(s.Name, "__sync_") ||
		strings.HasPrefix(s.Name, "__atomic_") {
		return true
	}

	// The global offset table is special-cased by the linker:
	if s.Name == "_GLOBAL_OFFSET_TABLE_" {
		return true
	}

	return false
}

// String returns the string representation, as displayed by `nm`.
func (c Class) String() string {
	return string([]byte{byte(c)})
}

// MarshalJSON implements the json.Marshaler interface.
func (c Class) MarshalJSON() ([]byte, error) {
	return json.Marshal(c.String())
}

// UnmarshalJSON implements the json.Unmarshaler interface.
func (c *Class) UnmarshalJSON(data []byte) error {
	s := ""
	if err := json.Unmarshal(data, &s); err != nil {
		return err
	}
	if len(s) != 1 {
		return fmt.Errorf("unknown class: %q", s)
	}
	*c = Class(s[0])
	return nil
}

// Len, Less and Swap implement sort.Interface.
func (al Archives) Len() int           { return len(al) }
func (al Archives) Less(i, j int) bool { return strings.Compare(al[i].Name, al[j].Name) < 0 }
func (al Archives) Swap(i, j int)      { al[i], al[j] = al[j], al[i] }
