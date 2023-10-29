#!/usr/bin/env bash

# Resolve a symbolic link.
# TODO: Check whether this is still necessary.
export EM_CONFIG="$(readlink -f "${EM_CONFIG}")"

# The actual location of the 'emcc' binary also comes from the environment.
exec "${EMCC}" $@
