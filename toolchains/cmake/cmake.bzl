"""CMake library macro.

Contains a convenience macro that wraps cmake() from
@rules_foreign_cc.
"""

load("@rules_foreign_cc//foreign_cc:cmake.bzl", "cmake")
load("//toolchains/make:configure.bzl", "WASM_ENV_VARS", "make_commands", _lib_source = "lib_source", _tools_deps = "tools_deps")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")

def cmake_lib(
        name,
        lib_source = None,
        after_cmake = None,
        after_emcmake = None,
        linkopts = None,
        out_static_libs = None,
        tools_deps = None,
        cache_entries = None,
        env = None,
        ignore_undefined_symbols = True,
        **kwargs):
    """Convenience macro that wraps cmake().

    Args:
      name: Passed on to cmake(). Also used for guessing other
        parameters.
      lib_source: Passed on to cmake(). Guessed from name.
      after_cmake: Commands to run after cmake.
      after_emcmake: Commands to run after emcmake (but not after plain cmake).
      linkopts: Passed on to cmake(). Guessed from name.
      out_static_libs: Passed on to cmake(). Guessed from name.
      tools_deps: Additional build-time dependencies, compiled with cfg =
        "exec".
      cache_entries: Convert True/False to "ON"/"OFF", then passed on to
        cmake().
      env: Passed on to cmake(). Form Emscripten builds, it is
        pre-populated with environment variables required by the toolchain.
      ignore_undefined_symbols: Whether to ignore undefined symbols. If False,
        any undefined symbols is the archive that are not provided by any of
        the dependencies will cause a build error for the archive symbols
        target.
      **kwargs: Passed on to cmake().
    """
    if lib_source == None:
        lib_source = _lib_source(name)
    if linkopts == None:
        linkopts = ["-l{}".format(name)]
    if out_static_libs == None:
        out_static_libs = ["lib{}.a".format(name)]
    if env == None:
        env = {}

    if cache_entries != None:
        if "//conditions:default" in cache_entries:
            # See: https://docs.bazel.build/versions/master/configurable-attributes.html#can-i-read-select-like-a-dict
            for val in cache_entries.values():
                _prepare_cache_entries(val)
            cache_entries = select(cache_entries)
        else:
            _prepare_cache_entries(cache_entries)
        kwargs["cache_entries"] = cache_entries

    cmake(
        name = name,
        env = select({
            "//config:wasm": dict(WASM_ENV_VARS.items() + env.items()),
            "//conditions:default": env,
        }),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        linkopts = linkopts,
        make_commands = make_commands(
            before_make = after_cmake,
            before_emmake = after_emcmake,
        ),
        out_static_libs = out_static_libs,
        tools_deps = _tools_deps(tools_deps),
        **kwargs
    )

    archive_symbols(
        name = name,
        deps = kwargs.get("deps", []),
        strict = not ignore_undefined_symbols,
    )

def _prepare_cache_entries(cache_entries):
    for key, val in cache_entries.items():
        if val in (True, False):
            cache_entries[key] = "ON" if val else "OFF"
