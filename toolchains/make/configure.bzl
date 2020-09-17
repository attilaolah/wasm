EM_CONFIG = 'EM_CONFIG="${EXT_BUILD_DEPS}/bin/emscripten_config.py"'
EM_CACHE = 'EM_CACHE="${EXT_BUILD_ROOT}/emscripten_cache"'

ENV_VARS = " ".join((EM_CONFIG, EM_CACHE))

EMCONFIGURE = [
    "echo '{} \"${{EXT_BUILD_DEPS}}/bin/emscripten/emconfigure\" $(dirname $0)/configure $@' >> emconfigure.sh".format(ENV_VARS),
    "chmod +x emconfigure.sh",
]

def emmake(make_command):
    return '{} "${{EXT_BUILD_DEPS}}/bin/emscripten/emmake" {}'.format(ENV_VARS, make_command)

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
