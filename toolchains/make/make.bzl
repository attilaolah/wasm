"""Make library macro.

Contains a convenience macro that wraps make() from @rules_foreign_cc.
"""

load("@rules_foreign_cc//foreign_cc:make.bzl", "make")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")
load(":configure.bzl", "build_data", "emscripten_env", _build_data = "build_data", _lib_source = "lib_source")

def make_lib(
        name,
        args = None,
        lib_source = None,
        build_data = None,
        linkopts = None,
        out_static_libs = None,
        env = None,
        ignore_undefined_symbols = True,
        **kwargs):
    """Convenience macro that wraps make().

    Args:
      name: Passed on to make(). Also used for guessing other parameters.
      args: Additional make args to pass to make().
      lib_source: Passed on to make(). Guessed from name.
      build_data: Additional build-time dependencies, compiled with cfg =
        "exec".
      linkopts: Passed on to make(). Guessed from name.
      out_static_libs: Passed on to make(). Guessed from name.
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
    if "//conditions:default" not in env:
        env = {
            "//config:wasm": dict(env),
            "//conditions:default": dict(env),
        }
    emscripten_env(env["//config:wasm"])

    make(
        name = name,
        env = select(env),
        args = args,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        build_data = _build_data(build_data),
        tool_prefix = select({
            "//config:wasm": "${EMSCRIPTEN}/emmake",
            "//conditions:default": None,
        }),
        linkopts = linkopts,
        out_static_libs = out_static_libs,
        **kwargs
    )

    archive_symbols(
        name = name,
        deps = kwargs.get("deps", []),
        strict = not ignore_undefined_symbols,
    )
