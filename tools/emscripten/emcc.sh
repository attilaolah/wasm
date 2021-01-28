#/usr/bin/env bash

# Run Emscripten's emcc, with the following modification:
# Set the EM_CONFIG environment variable to an absolute path.
# This avoids a bug where subcommands fail to find the config.

export EM_CONFIG="${PWD}/${EM_CONFIG}"
export EM_BINARYEN_ROOT="${PWD}/${EM_BINARYEN_ROOT}"
export EM_LLVM_ROOT="${PWD}/${EM_LLVM_ROOT}"
export EM_NODE_JS="${PWD}/${EM_NODE_JS}"

# Same applies for the Python interpreter.
export PYTHON="$(readlink -f "${PYTHON}")"

# The actual location of the 'emcc' binary also comes from the environment.

"${EMCC}" $@

