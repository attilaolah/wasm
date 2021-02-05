#!/usr/bin/env bash

if [[ -z "${PYTHONHOME}" ]]; then
  # PYTHONHOME not found in the environment.
  # Fall back to setting it based on EXT_BUILD_DEPS.
  if [[ -z "${EXT_BUILD_DEPS}" ]]; then
    echo "PYTHONHOME is not set!"
    echo "Additionally, it could not be guessed based on EXT_BUILD_DEPS."
    exit 1
  fi
  PYTHONHOME="${EXT_BUILD_DEPS}/bin/binaries"
fi

# Set PYTHONHOME to an absolute path.
export PYTHONHOME="$(readlink -f "${PYTHONHOME}")"
export PYTHON="${PYTHONHOME}/bin/python3"

exec "${PYTHON}" $@
