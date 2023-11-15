"""Configure+Make library macro.

Contains a convenience macro that wraps configure_make() from
@rules_foreign_cc.

Also contains most of the common functionality needed by Configure+Make, Make
and CMake macros.
"""

load("@rules_foreign_cc//foreign_cc:configure.bzl", "configure_make")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")
load(":make.bzl", "emscripten_env", _build_data = "build_data", _lib_source = "lib_source")

def configure_make_lib(
        name,
        lib_source = None,
        build_data = None,
        out_static_libs = None,
        env = None,
        ignore_undefined_symbols = True,
        **kwargs):
    """Convenience macro that wraps configure_make().

    Args:
      name: Passed on to configure_make(). Also used for guessing other
        parameters.
      lib_source: Passed on to configure_make(). Guessed from name.
      build_data: Additional build-time dependencies, compiled with cfg =
        "exec".
      out_static_libs: Passed on to configure_make(). Guessed from name.
      env: Passed on to configure_make(). Form Emscripten builds, it is
        pre-populated with environment variables required by the toolchain.
      ignore_undefined_symbols: Whether to ignore undefined symbols. If False,
        any undefined symbols is the archive that are not provided by any of
        the dependencies will cause a build error for the archive symbols
        target.
      **kwargs: Passed no configure_make().
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

    configure_make(
        name = name,
        env = select(env),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        build_data = _build_data(build_data, em_tools = ["@emscripten//:emconfigure"]),
        configure_prefix = select({
            "//config:wasm": " ".join([
                "EM_PKG_CONFIG_PATH=$${PKG_CONFIG_PATH:-}",
                "$(execpath @emscripten//:emconfigure)",
            ]),
            "//conditions:default": None,
        }),
        tool_prefix = select({
            "//config:wasm": "$(execpath @emscripten//:emmake)",
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
