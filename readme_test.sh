#!/usr/bin/env bash

# Consistency test for README.md.

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

exec bazel run //cmd/write_me --ui_event_filters=-INFO -- -root="${PWD}" \
  | diff --unified --color README.md - && (
    echo -e "${GREEN}PASS${NC}"
	exit 0
) || (
    echo -e "${RED}FAIL${NC}"
	echo "README.md is out of date! To regenerate it, run:"
	echo 'bazel run //cmd/write_me --ui_event_filters=-INFO -- -root="${PWD}" > README.md'
	exit 1
)
