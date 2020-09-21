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

def configure_command():
    return select({
        "//conditions:default": "configure",
        "//config:wasm64": "emconfigure.sh",
    })

def make_commands(commands = None):
    if commands == None:
        commands = ["make", "make install"]

    return select({
        "//conditions:default": commands,
        "//config:wasm64": [emmake(cmd) for cmd in commands],
    })

def lib_source(lib_name):
    return "@lib_{}//:all".format(lib_name)

def emmake(make_command):
    return '{} "${{EXT_BUILD_DEPS}}/bin/emscripten/emmake" {}'.format(ENV_CMD, make_command)
