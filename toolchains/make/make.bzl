"""Make library macro.

Contains a convenience macro that wraps make() from @rules_foreign_cc.
"""

load("@rules_foreign_cc//foreign_cc:make.bzl", "make")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")
load(":configure.bzl", "WASM_ENV_VARS", "tools_deps", _lib_source = "lib_source", _tools_deps = "tools_deps")

def make_lib(
        name,
        args = None,
        lib_source = None,
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
    if args == None:
        args = ['PREFIX="${INSTALLDIR}"']
    if lib_source == None:
        lib_source = _lib_source(name)
    if linkopts == None:
        linkopts = ["-l{}".format(name)]
    if out_static_libs == None:
        out_static_libs = ["lib{}.a".format(name)]
    if env == None:
        env = {}

    make(
        name = name,
        args = args,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        linkopts = linkopts,
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
