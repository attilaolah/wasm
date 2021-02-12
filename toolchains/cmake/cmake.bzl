"""CMake library macro.

Contains a convenience macro that wraps cmake_external() from
@rules_foreign_cc.
"""

load("@rules_foreign_cc//tools/build_defs:cmake.bzl", "cmake_external")
load("//toolchains/make:configure.bzl", "WASM_ENV_VARS", "make_commands", _lib_source = "lib_source", _tools_deps = "tools_deps")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")

def cmake_lib(
        name,
        lib_source = None,
        after_cmake = None,
        after_emcmake = None,
        linkopts = None,
        static_libraries = None,
        tools_deps = None,
        cache_entries = None,
        env = None,
        **kwargs):
    """Convenience macro that wraps cmake_external().

    Args:
      name: Passed on to cmake_external(). Also used for guessing other
        parameters.
      lib_source: Passed on to cmake_external(). Guessed from name.
      after_cmake: Commands to run after cmake.
      after_emcmake: Commands to run after emcmake (but not after plain cmake).
      linkopts: Passed on to cmake_external(). Guessed from name.
      static_libraries: Passed on to cmake_external(). Guessed from name.
      tools_deps: Additional build-time dependencies, compiled with cfg =
        "exec".
      cache_entries: Convert True/False to "ON"/"OFF", then passed on to
        cmake_external().
      env: Passed on to cmake_external(). Form Emscripten builds, it is
        pre-populated with environment variables required by the toolchain.
      **kwargs: Passed on to cmake_external().
    """
    if lib_source == None:
        lib_source = _lib_source(name)
    if linkopts == None:
        linkopts = ["-l{}".format(name)]
    if static_libraries == None:
        static_libraries = ["lib{}.a".format(name)]
    if env == None:
        env = {}
    wasm_env = dict(WASM_ENV_VARS.items() + env.items())

    if cache_entries != None:
        if "//conditions:default" in cache_entries:
            # See: https://docs.bazel.build/versions/master/configurable-attributes.html#can-i-read-select-like-a-dict
            for val in cache_entries.values():
                _prepare_cache_entries(val)
            cache_entries = select(cache_entries)
        else:
            _prepare_cache_entries(cache_entries)
        kwargs["cache_entries"] = cache_entries

    cmake_external(
        name = name,
        env = select({
            "//config:wasm32": wasm_env,
            "//config:wasm64": wasm_env,
            "//conditions:default": env,
        }),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        linkopts = linkopts,
        make_commands = make_commands(
            before_make = after_cmake,
            before_emmake = after_emcmake,
        ),
        static_libraries = static_libraries,
        tools_deps = _tools_deps(tools_deps),
        **kwargs
    )

    archive_symbols(name, kwargs.get("deps", []))

def _prepare_cache_entries(cache_entries):
    for key, val in cache_entries.items():
        if val in (True, False):
            cache_entries[key] = "ON" if val else "OFF"
