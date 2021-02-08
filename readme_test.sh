#!/usr/bin/env bash

# Consistency test for README.md.

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

# Simulate running as `bazel run //cmd/write_me`:
BUILD_WORKSPACE_DIRECTORY="$(dirname $(readlink -f "${0}"))" \
  "${WRITE_ME}" > README.md.golden

diff --unified --color README.md README.md.golden && (
    echo -e "${GREEN}PASS${NC}"
	exit 0
) || (
    echo -e "${RED}FAIL${NC}"
	echo "README.md is out of date! To regenerate it, run:"
	echo 'bazel run //cmd/write_me --ui_event_filters=-INFO -- -root="${PWD}" > README.md'
	exit 1
)
