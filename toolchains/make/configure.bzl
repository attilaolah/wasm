load("@rules_foreign_cc//tools/build_defs:configure.bzl", "configure_make")

WASM_ENV_VARS = {
    # Emscripten config from @emsdk//emscripten_toolchain:emscripten_config:
    "EM_CONFIG": "${EXT_BUILD_ROOT}/external/emsdk/emscripten_toolchain/emscripten_config",

    # The Emscripten config above requires ROOT_DIR and EMSCRIPTEN to be set:
    "ROOT_DIR": "${EXT_BUILD_ROOT}",
    "EMSCRIPTEN": "${EXT_BUILD_ROOT}/external/emscripten/emscripten",

    # Python from //tools/python:
    "PYTHON": "${EXT_BUILD_DEPS}/bin/python/python.sh",

    # Directory containing node_modules:
    "NODE_PATH": "${EXT_BUILD_DEPS}/bin",
}

WASM_TOOLS = [
    # keep sorted
    "//tools:nodejs",
    "//tools/python",
    "//tools/python:runtime",
    "@emscripten//:all",
    "@emsdk//emscripten_toolchain:emscripten_config",
    "@nodejs_linux_amd64//:node",
    "@npm//acorn",
]

TOOLS_DEPS = select({
    "//conditions:default": [],
    "//config:wasm32": WASM_TOOLS,
    "//config:wasm64": WASM_TOOLS,
})

def configure_make_lib(
        name,
        configure_options,
        static_libraries = None,
        deps = None,
        copts = None,
        env = None):
    if static_libraries == None:
        static_libraries = ["lib{}.a".format(name)]

    configure_env_vars = {}
    if copts != None:
        configure_env_vars["CFLAGS"] = " ".join(copts)

    if env == None:
        env = {}
    wasm_env = dict(WASM_ENV_VARS.items() + env.items())

    configure_make(
        name = name,
        configure_command = select({
            "//conditions:default": "configure",
            "//config:wasm32": "emconfigure.sh",
            "//config:wasm64": "emconfigure.sh",
        }),
        configure_options = configure_options,
        configure_env_vars = configure_env_vars,
        env = select({
            "//conditions:default": env,
            "//config:wasm32": wasm_env,
            "//config:wasm64": wasm_env,
        }),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source(name),
        linkopts = ["-l{}".format(name)],
        make_commands = make_commands(),
        static_libraries = static_libraries,
        deps = deps or [],
        tools_deps = TOOLS_DEPS,
    )

def make_commands(
        commands = None,
        before_make = None,
        after_make = None,
        before_emmake = None,
        after_emmake = None):
    if commands == None:
        commands = ["make", "make install"]
    wasm_commands = [_emmake(cmd) for cmd in commands]

    if before_make != None:
        commands = before_make + commands
    if after_make != None:
        commands += after_make

    if before_emmake != None:
        wasm_commands = before_emmake + wasm_commands
    if after_emmake != None:
        wasm_commands += after_emmake

    return select({
        "//conditions:default": commands,
        "//config:wasm32": wasm_commands,
        "//config:wasm64": wasm_commands,
    })

def lib_source(lib_name):
    return "@lib_{}//:all".format(lib_name)

def patch_files(patch_map):
    """Generates a list of 'sed' commands that patch files in-place."""
    return [
        "sed --in-place --regexp-extended '{}' \"{}\"".format(regex, filename)
        for filename, regex in sorted(patch_map.items())
    ]

def _emmake(make_command):
    return '"${{EXT_BUILD_DEPS}}/bin/emscripten/emscripten/emmake" {}'.format(make_command)
