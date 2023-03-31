#!/usr/bin/env bash

# Consistency test for README.md.

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

# Simulate running as `bazel run //cmd/write_me`:
BUILD_WORKSPACE_DIRECTORY="$(dirname $(dirname $(readlink -f "${0}")))" \
  "${WRITE_ME}" -output="${PWD}/README.md.golden"

diff --unified --color README.md README.md.golden && (
    echo -e "${GREEN}PASS${NC}"
    exit 0
) || (
    echo -e "${RED}FAIL${NC}"
    echo "README.md is out of date! To regenerate it, run:"
    echo "bazel run //cmd/write_me"
    exit 1
)
