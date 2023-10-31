"""Configure+Make library macro.

Contains a convenience macro that wraps configure_make() from
@rules_foreign_cc.

Also contains most of the common functionality needed by Configure+Make, Make
and CMake macros.
"""

load("@bazel_skylib//lib:collections.bzl", "collections")
load("@rules_foreign_cc//foreign_cc:configure.bzl", "configure_make")
load("//lib:defs.bzl", "dep_path", "repo_name", "root_path")
load("//tools:parsed_headers.bzl", "parsed_headers")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")

EM_ENV = {
    # NodeJS cross-compiling emulator:
    "CROSSCOMPILING_EMULATOR": root_path("$(execpath @nodejs_host//:node)", double_escape = True),

    # Emscripten config from @emsdk:
    "EM_CONFIG": "$(execpath @emsdk//emscripten_toolchain:emscripten_config)",

    # Required (?) by the Emscripten config above:
    "EMSCRIPTEN": root_path("external/emscripten_bin_linux/emscripten", double_escape = True),

    # Directory containing node_modules:
    "NODE_PATH": "$${EXT_BUILD_DEPS}/bin",

    # Python from //lib/python:
    "PYTHONHOME": root_path("$(execpaths //lib/python:runtime)", double_escape = True),

    # Required by the Emscripten config:
    "ROOT_DIR": "$${EXT_BUILD_ROOT}",
}

# Python from //lib/python.
# This must come after ${PYTHONHOME}.
EM_ENV["PYTHON"] = "$${PYTHONHOME}/bin/python3"

EM_TOOLS = [
    # keep sorted
    "//lib/python:runtime",
    "//tools:nodejs",
    "@emscripten_bin_linux//:emcc_common",
    "@emscripten_bin_linux//:emscripten/emcc",
    "@emscripten_bin_linux//:emscripten/emcmake",
    "@emscripten_bin_linux//:emscripten/emconfigure",
    "@emscripten_bin_linux//:emscripten/emmake",
    "@emsdk//emscripten_toolchain:emscripten_config",
    "@nodejs_host//:node",
    "@npm//acorn",
]

def configure_make_lib(
        name,
        lib_source = None,
        build_data = None,
        hdrs = None,
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
      hdrs: List of headers to parse and generate symbols for.
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
        build_data = _build_data(build_data),
        configure_prefix = select({
            "//config:wasm": "$(execpath @emscripten_bin_linux//:emscripten/emconfigure)",
            "//conditions:default": None,
        }),
        tool_prefix = select({
            "//config:wasm": "$(execpath @emscripten_bin_linux//:emscripten/emmake)",
            "//conditions:default": None,
        }),
        out_static_libs = out_static_libs,
        **kwargs
    )

    if hdrs != None:
        parsed_headers(
            name = "{}_h".format(name),
            deps = [":{}".format(name)],
            hdrs = hdrs,
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

    if type(extras) != type({}):
        extras = {
            "//conditions:default": extras,
            "//config:wasm": extras,
        }
    extras.setdefault("//config:wasm", [])
    extras["//config:wasm"] = collections.uniq(EM_TOOLS + extras["//config:wasm"])

    return select(extras)

_build_data = build_data

def lib_source(lib_name):
    return "@{}//:all".format(repo_name(lib_name))

_lib_source = lib_source

def emscripten_env(env):
    """Set Emscripten environment variables."""
    env.update(EM_ENV)
