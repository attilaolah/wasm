#!/usr/bin/env bash

if [[ -z "${ROOT_PATH}" ]]; then
  ROOT_PATH_ORIG="${ROOT_PATH}"
  ROOT_PATH="${EXT_BUILD_DEPS}/bin/python_lib"
fi

PYTHON="${ROOT_PATH}/bin/python3"

if [[ ! -x "${PYTHON}" ]]; then
  echo "Python not found!"
  echo "EXT_BUILD_DEPS: ${EXT_BUILD_DEPS}"
  echo "ROOT_PATH: ${ROOT_PATH_ORIG}"
  exit 1
fi

PYTHONHOME="$(dirname $(dirname "${PYTHON}"))"
PYTHONHOME="$(readlink -f "${PYTHONHOME}")"

export PYTHONHOME

exec "${PYTHON}" $@
