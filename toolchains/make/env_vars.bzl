# These are in aseparate file so that EMCONFIGURE would not have any external dependencies.
# This is to avoid cylcic dependencies since EMCONFIGURE is used to patch repos before loading them.

# TODO: Use macros for these!
WASM_ENV_VARS = {
    "EM_CACHE": "${EXT_BUILD_ROOT}/emscripten_cache",
    "EM_CONFIG": "${EXT_BUILD_DEPS}/config/emscripten_config.py",
    "NODE_PATH": "${EXT_BUILD_DEPS}/bin",

    # Python from //tools/python
    "PYTHON": "${EXT_BUILD_DEPS}/bin/python/bin/python3",
    # Python runtime from //tools/python:runtime
    "PYTHONHOME": "${EXT_BUILD_DEPS}/bin/python",
}

def _quote(text):
    # Like shell.quote() from @bazel_skylib//lib:shell.bzl, but uses double quotes.
    return '"' + text.replace('"', '"\\""') + '"'

EMCONFIGURE = [
    "echo '\"${EXT_BUILD_DEPS}/bin/emscripten/emconfigure\" $(dirname $0)/configure $@' >> emconfigure.sh",
    "chmod +x emconfigure.sh",
]
