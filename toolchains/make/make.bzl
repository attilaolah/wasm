"""Make library macro.

Contains a convenience macro that wraps make() from @rules_foreign_cc.
"""

load("@rules_foreign_cc//foreign_cc:make.bzl", "make")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")
load(":configure.bzl", "WASM_ENV_VARS", "tools_deps", _lib_source = "lib_source", _make_commands = "make_commands", _tools_deps = "tools_deps")

def make_lib(
        name,
        lib_source = None,
        make_commands = None,
        install_commands = None,
        linkopts = None,
        out_static_libs = None,
        tools_deps = None,
        env = None,
        ignore_undefined_symbols = True,
        **kwargs):
    """Convenience macro that wraps make().

    Args:
      name: Passed on to make(). Also used for guessing other parameters.
      lib_source: Passed on to make(). Guessed from name.
      make_commands: Wrapped in a select() for Emscripten, then passed on to
        make().
      install_commands: Commands to run after either make or emmake. For
        Emscripten, these are NOT prefixed with emmake.
      linkopts: Passed on to make(). Guessed from name.
      out_static_libs: Passed on to make(). Guessed from name.
      tools_deps: Additional build-time dependencies, compiled with cfg =
        "exec".
      env: Passed on to make(). Form Emscripten builds, it is
        pre-populated with environment variables required by the toolchain.
      ignore_undefined_symbols: Whether to ignore undefined symbols. If False,
        any undefined symbols is the archive that are not provided by any of
        the dependencies will cause a build error for the archive symbols
        target.
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
    if out_static_libs == None:
        out_static_libs = ["lib{}.a".format(name)]
    if env == None:
        env = {}

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
            "//config:wasm": dict(WASM_ENV_VARS.items() + env.items()),
            "//conditions:default": env,
        }),
        out_static_libs = out_static_libs,
        tools_deps = _tools_deps(tools_deps),
        **kwargs
    )

    archive_symbols(
        name = name,
        deps = kwargs.get("deps", []),
        strict = not ignore_undefined_symbols,
    )
