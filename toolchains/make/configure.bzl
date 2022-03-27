"""Configure+Make library macro.

Contains a convenience macro that wraps configure_make() from
@rules_foreign_cc.

Also contains most of the common functionality needed by Configure+Make, Make
and CMake macros.
"""

load("@bazel_skylib//lib:collections.bzl", "collections")
load("@rules_foreign_cc//foreign_cc:configure.bzl", "configure_make")
load("//lib:defs.bzl", "repo_name")
load("//toolchains:utils.bzl", "path")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")

EM_ENV = {
    # NodeJS cross-compiling emulator:
    "CROSSCOMPILING_EMULATOR": "${EXT_BUILD_ROOT}/external/nodejs_linux_amd64/bin/node",

    # Required by the Emscripten config:
    "EMSCRIPTEN": "${EXT_BUILD_ROOT}/external/emscripten_bin_linux/emscripten",

    # Emscripten config from @emsdk//emscripten_toolchain:emscripten_config:
    "EM_CONFIG": "${EXT_BUILD_ROOT}/external/emsdk/emscripten_toolchain/emscripten_config",

    # Directory containing node_modules:
    "NODE_PATH": "${EXT_BUILD_DEPS}/bin",

    # Python from //lib/python:
    "PYTHONHOME": "${EXT_BUILD_ROOT}/$(execpaths //lib/python:runtime)",

    # Required by the Emscripten config:
    "ROOT_DIR": "${EXT_BUILD_ROOT}",
}

# Python from //lib/python:
EM_PATH = path(["${EXT_BUILD_ROOT}/$(execpaths //lib/python:runtime)/bin"])

EM_TOOLS = [
    # keep sorted
    "//lib/python:runtime",
    "//tools:nodejs",
    "@emscripten_bin_linux//:all",
    "@emsdk//emscripten_toolchain:emscripten_config",
    "@nodejs_linux_amd64//:node",
    "@npm//acorn",
]

def configure_make_lib(
        name,
        lib_source = None,
        build_data = None,
        linkopts = None,
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
      linkopts: Passed on to configure_make(). Guessed from name.
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

    configure_make(
        name = name,
        env = select(env),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        build_data = _build_data(build_data),
        configure_prefix = select({
            "//config:wasm": "${EMSCRIPTEN}/emconfigure",
            "//conditions:default": None,
        }),
        tool_prefix = select({
            "//config:wasm": "${EMSCRIPTEN}/emmake",
            "//conditions:default": None,
        }),
        linkopts = linkopts,
        out_static_libs = out_static_libs,
        **kwargs
    )

    archive_symbols(
        archive = name,
        deps = kwargs.get("deps", []),
        strict = not ignore_undefined_symbols,
    )

def build_data(extras = None):
    """Extends build_data with extras.

    For Emscripten, merges extras with EM_TOOLS. Otherwise it simply selects
    extras for build_data.

    Args:
      extras: Existing build_data to extend.

    Returns:
      A select() wrapping the resulting build_data.
    """
    if extras == None:
        extras = []

    return select({
        "//config:wasm": collections.uniq(EM_TOOLS + extras),
        "//conditions:default": extras,
    })

_build_data = build_data

def lib_source(lib_name):
    return "@{}//:all".format(repo_name(lib_name))

_lib_source = lib_source

def emscripten_env(env):
    """Set Emscripten environment variables."""
    env.update(EM_ENV)
    env.setdefault("PATH", "${PATH}")
    env["PATH"] = path([EM_PATH], existing = env["PATH"])
