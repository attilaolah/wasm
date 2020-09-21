# These are in aseparate file so that EMCONFIGURE would not have any external dependencies.
# This is to avoid cylcic dependencies since EMCONFIGURE is used to patch repos before loading them.

ENV_VARS = {
    "EM_CACHE": "${EXT_BUILD_ROOT}/emscripten_cache",
    "EM_CONFIG": "${EXT_BUILD_DEPS}/bin/emscripten_config.py",
    "NODE_PATH": "${EXT_BUILD_DEPS}/bin",
}

def _quote(text):
    # Like shell.quote() from @bazel_skylib//lib:shell.bzl, but uses double quotes.
    return '"' + text.replace('"', '"\\""') + '"'

ENV_CMD = " ".join(sorted(["=".join((key, _quote(val))) for key, val in ENV_VARS.items()]))

EMCONFIGURE = [
    "echo '{} \"${{EXT_BUILD_DEPS}}/bin/emscripten/emconfigure\" $(dirname $0)/configure $@' >> emconfigure.sh".format(ENV_CMD),
    "chmod +x emconfigure.sh",
]
