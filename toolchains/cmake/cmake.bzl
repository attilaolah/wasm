"""CMake library macro.

Contains a convenience macro that wraps cmake() from
@rules_foreign_cc.
"""

load("@rules_foreign_cc//foreign_cc:cmake.bzl", "cmake")
load("//lib:cache_entries.bzl", "include_dir_key", "library_key")
load("//lib:defs.bzl", "dep_spec")
load("//toolchains/make:configure.bzl", "emscripten_env", _build_data = "build_data", _lib_source = "lib_source")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")

def cmake_lib(
        name,
        lib_source = None,
        build_data = None,
        out_static_libs = None,
        cache_entries = None,
        env = None,
        ignore_undefined_symbols = True,
        **kwargs):
    """Convenience macro that wraps cmake().

    Args:
      name: Passed on to cmake(). Also used for guessing other parameters.
      lib_source: Passed on to cmake(). Guessed from name.
      build_data: Additional build-time dependencies, compiled with cfg =
        "exec".
      out_static_libs: Passed on to cmake(). Guessed from name.
      cache_entries: Convert True/False to "ON"/"OFF", then passed on to
        cmake().
      env: Passed on to cmake(). Form Emscripten builds, it is pre-populated
        with environment variables required by the toolchain.
      ignore_undefined_symbols: Whether to ignore undefined symbols. If False,
        any undefined symbols is the archive that are not provided by any of
        the dependencies will cause a build error for the archive symbols
        target.
      **kwargs: Passed on to cmake().
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

    if cache_entries == None:
        cache_entries = {}
    if "//conditions:default" not in cache_entries:
        cache_entries = {
            "//config:wasm": dict(cache_entries),
            "//conditions:default": dict(cache_entries),
        }
    for val in cache_entries.values():
        _prepare_cache_entries(val)
    _emscripten_cache_entries(cache_entries["//config:wasm"])

    cmake(
        name = name,
        env = select(env),
        cache_entries = select(cache_entries),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        build_data = _build_data(build_data),
        tool_prefix = select({
            "//config:wasm": " ".join([
                "EM_PKG_CONFIG_PATH=$${PKG_CONFIG_PATH:-}",
                "$(execpath @emscripten_bin_linux//:emscripten/emcmake)",
	    ]),
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

def cache_entries(*originals, upcase = True, prefix_all = "", deps = None, **kwargs):
    """Convenience macro for constructing the cache_entries dict."""
    result = {}
    for original in originals + (kwargs,):
        result.update(original)

    remap = result.pop("remap", {})

    for dep, spec in (deps or {}).items():
        spec = spec or dep_spec(dep)
        if "include_dir" in spec:
            result[include_dir_key(dep)] = spec["include_dir"]
        if "library" in spec:
            result[library_key(dep)] = spec["library"]

    for new, old in remap.items():
        result[new] = result.pop(old)

    if upcase:
        for key in list(result):
            result[key.upper()] = result.pop(key)

    return {prefix_all + key: val for key, val in result.items()}

def _prepare_cache_entries(cache_entries):
    for key, val in cache_entries.items():
        if val in (True, False):
            cache_entries[key] = "ON" if val else "OFF"

def _emscripten_cache_entries(cache_entries):
    """Set Emscripten-specific CMake cache entries."""
    external = "${EXT_BUILD_ROOT}/external"
    cmake_modules = "{}/emscripten_bin_linux/emscripten/cmake/Modules".format(external)

    # As suggested by rules_foreign_cc docs.
    cache_entries["CMAKE_SYSTEM_NAME"] = "Emscripten"
    cache_entries["CMAKE_MODULE_PATH"] = cmake_modules
    cache_entries["CMAKE_TOOLCHAIN_FILE"] = "{}/Platform/Emscripten.cmake".format(cmake_modules)
    cache_entries["CMAKE_CROSSCOMPILING_EMULATOR"] = "{}/nodejs_host/bin/node".format(external)
