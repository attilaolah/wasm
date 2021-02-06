"""Configure+Make library macro.

Contains a convenience macro that wraps configure_make() from
@rules_foreign_cc.

Also contains most of the common functionality needed by Configure+Make, Make
and CMake macros.
"""

load("@rules_foreign_cc//tools/build_defs:configure.bzl", "configure_make")

WASM_ENV_VARS = {
    # Required by the Emscripten config:
    "EMSCRIPTEN": "${EXT_BUILD_ROOT}/external/emscripten/emscripten",

    # Emscripten config from @emsdk//emscripten_toolchain:emscripten_config:
    "EM_CONFIG": "${EXT_BUILD_ROOT}/external/emsdk/emscripten_toolchain/emscripten_config",

    # Directory containing node_modules:
    "NODE_PATH": "${EXT_BUILD_DEPS}/bin",

    # Python from //tools/python:
    "PYTHON": "${EXT_BUILD_DEPS}/bin/python/python.sh",

    # Required by the Emscripten config:
    "ROOT_DIR": "${EXT_BUILD_ROOT}",
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
    "//config:wasm32": WASM_TOOLS,
    "//config:wasm64": WASM_TOOLS,
    "//conditions:default": [],
})

def configure_make_lib(
        name,
        static_libraries = None,
        copts = None,
        env = None,
        **kwargs):
    """Convenience macro that wraps configure_make().

    Args:
      name: Passed on to configure_make(). Also used for guessing other
        parameters.
      static_libraries: Passed on to configure_make(). Guessed from name.
      copts: Additional compile options, appended to the CFLAGS configure
        environment variable.
      env: Passed on to configure_make(). Form Emscripten builds, it is
        pre-populated with environment variables required by the toolchain.
      **kwargs: Passed no configure_make().
    """
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
            "//config:wasm32": "emconfigure.sh",
            "//config:wasm64": "emconfigure.sh",
            "//conditions:default": "configure",
        }),
        configure_env_vars = configure_env_vars,
        env = select({
            "//config:wasm32": wasm_env,
            "//config:wasm64": wasm_env,
            "//conditions:default": env,
        }),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source(name),
        linkopts = ["-l{}".format(name)],
        make_commands = make_commands(),
        static_libraries = static_libraries,
        tools_deps = TOOLS_DEPS,
        **kwargs
    )

def make_commands(
        commands = None,
        before_make = None,
        after_make = None,
        before_emmake = None,
        after_emmake = None):
    """Generate make commands for the target platform.

    By default, returns the passed-in commands. For Emscripten builds, prefixes
    the commands with "emmake".

    Args:
      commands: Commands, as a list of strings.
      before_make: Commands to run before make, but not before emmake.
      after_make: Commands to run after make, but not after emmake.
      before_emmake: Commands to run before emmake, but not before make.
      after_emmake: Commands to run after emmake, but not after make.

    Returns:
      A select() wrapping the resulting make commands.
    """
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
        "//config:wasm32": wasm_commands,
        "//config:wasm64": wasm_commands,
        "//conditions:default": commands,
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
