"""Make library macro.

Contains a convenience macro that wraps make() from @rules_foreign_cc.
"""

load("@rules_foreign_cc//tools/build_defs:make.bzl", "make")
load("//tools:archive_symbols.bzl", "archive_symbols")
load(":configure.bzl", "WASM_ENV_VARS", "tools_deps", _lib_source = "lib_source", _make_commands = "make_commands")

def make_lib(
        name,
        lib_source = None,
        make_commands = None,
        install_commands = None,
        linkopts = None,
        static_libraries = None,
        env = None,
        **kwargs):
    """Convenience macro that wraps make().

    Args:
      name: Passed on to make(). Also used for guessing other parameters.
      lib_source: Passed on to make(). Guessed from name.
      make_commands: Wrapped in a select() for Emscripten, then passed on to
        make().
      install_commands: Commands to run after either make or emmake. For
        Emscripten, these are NOT prefixed with emmake.
      linkopts: Passed on to cmake_external(). Guessed from name.
      static_libraries: Passed on to make(). Guessed from name.
      env: Passed on to make(). Form Emscripten builds, it is
        pre-populated with environment variables required by the toolchain.
      **kwargs: Passed no make().
    """
    if lib_source == None:
        lib_source = _lib_source(name)
    if make_commands == None:
        make_commands = [
            'make -C "${{EXT_BUILD_ROOT}}/external/lib_{}"'.format(name),
            'make -C "${{EXT_BUILD_ROOT}}/external/lib_{}" install PREFIX="${{INSTALLDIR}}"'.format(name),
        ]
    if linkopts == None:
        linkopts = ["-l{}".format(name)]
    if static_libraries == None:
        static_libraries = ["lib{}.a".format(name)]
    if env == None:
        env = {}
    wasm_env = dict(WASM_ENV_VARS.items() + env.items())

    make(
        name = name,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        linkopts = linkopts,
        make_commands = _make_commands(
            commands = make_commands,
            after_make = install_commands,
            after_emmake = install_commands,
        ),
        env = select({
            "//config:wasm32": wasm_env,
            "//config:wasm64": wasm_env,
            "//conditions:default": env,
        }),
        static_libraries = static_libraries,
        tools_deps = tools_deps(),
        **kwargs
    )

    archive_symbols(
        name = "{}_symbols".format(name),
        srcs = [":{}".format(name)],
    )
