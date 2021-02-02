#/usr/bin/env bash

# Run Emscripten's emcc, with the following modification:
# Set the EM_CONFIG environment variable to an absolute path.
# This avoids a bug where subcommands fail to find the config.

export EM_CONFIG="$(readlink -f "${EM_CONFIG}")"
export EM_CACHE="$(readlink -f "${EM_CACHE}")"
export EM_BINARYEN_ROOT="$(readlink -f "${EM_BINARYEN_ROOT}")"
export EM_LLVM_ROOT="$(readlink -f "${EM_LLVM_ROOT}")"
export EM_NODE_JS="$(readlink -f "${EM_NODE_JS}")"

# Same applies for the Python interpreter.
export PYTHON="$(readlink -f "${PYTHON}")"
export PYTHONHOME="$(readlink -f "${PYTHONHOME}")"

# The actual location of the 'emcc' binary also comes from the environment.

"${EMCC}" $@

