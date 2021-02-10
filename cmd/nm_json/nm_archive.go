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
	"strconv"
	"strings"
)

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
	Class   Class   `json:"class"`
	Type    string  `json:"type"`
	Size    *uint64 `json:"size,omitempty"`
	Line    string  `json:"line,omitempty"`
	Section string  `json:"section"`
}

// Class is the class column returned by `nm --format=sysv`.
type Class byte

// ParseArchive executes `nm` on a single archive.
func ParseArchive(nm, path string, extern bool) (*Archive, error) {
	args := []string{"--format=sysv", "--no-sort"}
	if extern {
		args = append(args, "--extern-only")
	}
	cmd := exec.Command(nm, append(args, path)...)

	out, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("error running command %q: %w; output: %s", cmd, err, out)
	}

	a, err := Parse(bytes.NewBuffer(out))
	if err != nil {
		return nil, err
	}
	_, name := filepath.Split(path)
	a.Name = name

	return a, nil
}

// Parse parses `nm --format=sysv` output.
func Parse(src io.Reader) (*Archive, error) {
	a := Archive{}
	var o *Object

	ln := 0
	scanner := bufio.NewScanner(src)
	for scanner.Scan() {
		line := scanner.Text()
		ln++

		t := strings.TrimSpace(line)
		if t == "" {
			continue
		}
		if strings.HasPrefix(t, "Symbols from ") && strings.HasSuffix(t, ":") {
			t = strings.TrimPrefix(t, "Symbols from ")
			t = strings.TrimSuffix(t, ":")
			parts := strings.FieldsFunc(t, func(r rune) bool {
				return r == '[' || r == ']'
			})
			if len(parts) == 1 {
				o = &Object{Name: parts[0]}
				a.Objects = append(a.Objects, o)
				continue
			}
			if len(parts) != 2 {
				return nil, fmt.Errorf("line %d: %q: failed to parse as `archive[object]:` or `object:`", ln, line)
			}

			if _, aname := filepath.Split(parts[0]); a.Name == "" {
				a.Name = aname
			} else if a.Name != aname {
				return nil, fmt.Errorf("line %d: %q: more than one archive in a single stream", ln, line)
			}
			o = &Object{Name: parts[1]}
			a.Objects = append(a.Objects, o)
			continue
		}
		parts := strings.Split(t, "|")
		if len(parts) == 1 {
			// Header (Name, Value, Class…)
			continue
		}
		if l := len(parts); l != 7 {
			return nil, fmt.Errorf("line %d: %q: row contains %d columns instead of 7", ln, line, l)
		}
		s := Symbol{
			Name:    strings.TrimSpace(parts[0]),
			Type:    strings.TrimSpace(parts[3]),
			Line:    strings.TrimSpace(parts[5]),
			Section: strings.TrimSpace(parts[6]),
		}
		if v := strings.TrimSpace(parts[2]); len(v) == 1 {
			s.Class = Class(v[0])
		} else {
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

		o.Symbols = append(o.Symbols, &s)
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("failed to scan line: %w", err)
	}

	return &a, nil
}

// String returns the string representation, as displayed by `nm`.
func (c Class) String() string {
	return string([]byte{byte(c)})
}

// MarshalJSON implements the json.Marshaler interface.
func (c Class) MarshalJSON() ([]byte, error) {
	return json.Marshal(c.String())
}
