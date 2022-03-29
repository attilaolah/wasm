"""Make library macro.

Contains a convenience macro that wraps make() from @rules_foreign_cc.
"""

load("@rules_foreign_cc//foreign_cc:make.bzl", "make")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")
load(":configure.bzl", "build_data", "emscripten_env", _build_data = "build_data", _lib_source = "lib_source")

def make_lib(
        name,
        lib_source = None,
        build_data = None,
        out_static_libs = None,
        env = None,
        ignore_undefined_symbols = True,
        **kwargs):
    """Convenience macro that wraps make().

    Args:
      name: Passed on to make(). Also used for guessing other parameters.
      lib_source: Passed on to make(). Guessed from name.
      build_data: Additional build-time dependencies, compiled with cfg =
        "exec".
      out_static_libs: Passed on to make(). Guessed from name.
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
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        build_data = _build_data(build_data),
        tool_prefix = select({
            "//config:wasm": "$(execpath @emscripten_bin_linux//:emscripten/emmake)",
            "//conditions:default": None,
        }),
        out_static_libs = out_static_libs,
        **kwargs
    )

    archive_symbols(
        archive = name,
        deps = kwargs.get("deps", []),
        strict = not ignore_undefined_symbols,
    )
