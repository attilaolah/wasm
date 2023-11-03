#!/usr/bin/env bash

export ROOT_DIR="${PWD}"
export EM_CONFIG="$(readlink -f "${EM_CONFIG}")"

# The actual location of the 'emcc' binary also comes from the environment.
exec "${EMCC}" $@
