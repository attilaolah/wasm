"""Configure+Make library macro.

Contains a convenience macro that wraps configure_make() from
@rules_foreign_cc.

Also contains most of the common functionality needed by Configure+Make, Make
and CMake macros.
"""

load("@bazel_skylib//lib:collections.bzl", "collections")
load("@rules_foreign_cc//tools/build_defs:configure.bzl", "configure_make")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")

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
    "//lib/python:runtime",
    "//tools:nodejs",
    "//tools/python",
    "@emscripten//:all",
    "@emsdk//emscripten_toolchain:emscripten_config",
    "@nodejs_linux_amd64//:node",
    "@npm//acorn",
]

def configure_make_lib(
        name,
        lib_source = None,
        configure_script = "configure",
        make_commands = None,
        linkopts = None,
        static_libraries = None,
        tools_deps = None,
        env = None,
        ignore_undefined_symbols = False,
        **kwargs):
    """Convenience macro that wraps configure_make().

    Args:
      name: Passed on to configure_make(). Also used for guessing other
        parameters.
      lib_source: Passed on to configure_make(). Guessed from name.
      configure_script: Name of the configure script to run.
      make_commands: Wrapped in a select() for Emscripten, then passed on to
        configure_make().
      linkopts: Passed on to configure_make(). Guessed from name.
      static_libraries: Passed on to configure_make(). Guessed from name.
      tools_deps: Additional build-time dependencies, compiled with cfg =
        "exec".
      env: Passed on to configure_make(). Form Emscripten builds, it is
        pre-populated with environment variables required by the toolchain.
      ignore_undefined_symbols: Whether to ignore undefined symbols. If False
        (the default), any undefined symbols is the archive that are not
        provided by any of the dependencies will cause a build error for the
        archive symbols target.
      **kwargs: Passed no configure_make().
    """
    if lib_source == None:
        lib_source = _lib_source(name)
    if make_commands == None:
        make_commands = [
            "make",
            "make install",
        ]
    if linkopts == None:
        linkopts = ["-l{}".format(name)]
    if static_libraries == None:
        static_libraries = ["lib{}.a".format(name)]

    if env == None:
        env = {}
    wasm_env = dict(WASM_ENV_VARS.items() + env.items())
    wasm_env["CONFIGURE"] = configure_script

    configure_make(
        name = name,
        configure_command = select({
            "//config:wasm": "emconfigure.sh",
            "//conditions:default": configure_script,
        }),
        env = select({
            "//config:wasm": wasm_env,
            "//conditions:default": env,
        }),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        linkopts = linkopts,
        make_commands = _make_commands(commands = make_commands),
        static_libraries = static_libraries,
        tools_deps = _tools_deps(tools_deps),
        **kwargs
    )

    archive_symbols(
        name = name,
        deps = kwargs.get("deps", []),
        strict = not ignore_undefined_symbols,
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
        "//config:wasm": wasm_commands,
        "//conditions:default": commands,
    })

_make_commands = make_commands

def tools_deps(extras = None):
    """Extends tools_deps with extras.

    For Emscripten, merges extras with WASM_TOOLS. Otherwise it simply selects
    extras for tools_deps.

    Args:
      extras: Existing tools_deps to extend.

    Returns:
      A select() wrapping the resulting tools_deps.
    """
    if extras == None:
        extras = []

    return select({
        "//config:wasm": collections.uniq(WASM_TOOLS + extras),
        "//conditions:default": extras,
    })

_tools_deps = tools_deps

def lib_source(lib_name):
    return "@lib_{}//:all".format(lib_name)

_lib_source = lib_source

def patch_files(patch_map):
    """Generates a list of 'sed' commands that patch files in-place."""
    return [
        "sed --in-place --regexp-extended '{}' \"{}\"".format(regex, filename)
        for filename, regex in sorted(patch_map.items())
    ]

def _emmake(make_command):
    return '"${{EXT_BUILD_DEPS}}/bin/emscripten/emscripten/emmake" {}'.format(make_command)
