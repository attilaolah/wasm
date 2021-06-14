"""Configure+Make library macro.

Contains a convenience macro that wraps configure_make() from
@rules_foreign_cc.

Also contains most of the common functionality needed by Configure+Make, Make
and CMake macros.
"""

load("@bazel_skylib//lib:collections.bzl", "collections")
load("@rules_foreign_cc//foreign_cc:configure.bzl", "configure_make")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")

WASM_ENV_VARS = {
    # Required by the Emscripten config:
    "EMSCRIPTEN": "${EXT_BUILD_ROOT}/external/emscripten/emscripten",

    # Emscripten config from @emsdk//emscripten_toolchain:emscripten_config:
    "EM_CONFIG": "${EXT_BUILD_ROOT}/external/emsdk/emscripten_toolchain/emscripten_config",

    # Directory containing node_modules:
    "NODE_PATH": "${EXT_BUILD_DEPS}/bin",

    # Python from //tools/python:
    "PYTHON": "${EXT_BUILD_DEPS}/bin/python/python.sh",

    # Required by the Emscripten config:
    "ROOT_DIR": "${EXT_BUILD_ROOT}",
}

WASM_TOOLS = [
    # keep sorted
    "//lib/python:runtime",
    "//tools:nodejs",
    "//tools/python",
    "@emscripten//:all",
    "@emsdk//emscripten_toolchain:emscripten_config",
    "@nodejs_linux_amd64//:node",
    "@npm//acorn",
]

def configure_make_lib(
        name,
        lib_source = None,
        build_data = None,
        configure_script = "configure",
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
      configure_script: Name of the configure script to run.
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
    wasm_env = dict(WASM_ENV_VARS.items() + env.items())
    wasm_env["CONFIGURE"] = configure_script

    configure_make(
        name = name,
        configure_command = select({
            "//config:wasm": "emconfigure.sh",
            "//conditions:default": configure_script,
        }),
        env = select({
            "//config:wasm": wasm_env,
            "//conditions:default": env,
        }),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        build_data = _build_data(build_data),
        linkopts = linkopts,
        out_static_libs = out_static_libs,
        **kwargs
    )

    archive_symbols(
        name = name,
        deps = kwargs.get("deps", []),
        strict = not ignore_undefined_symbols,
    )

def build_data(extras = None):
    """Extends build_data with extras.

    For Emscripten, merges extras with WASM_TOOLS. Otherwise it simply selects
    extras for build_data.

    Args:
      extras: Existing build_data to extend.

    Returns:
      A select() wrapping the resulting build_data.
    """
    if extras == None:
        extras = []

    return select({
        "//config:wasm": collections.uniq(WASM_TOOLS + extras),
        "//conditions:default": extras,
    })

_build_data = build_data

def lib_source(lib_name):
    return "@lib_{}//:all".format(lib_name)

_lib_source = lib_source

def patch_files(patch_map):
    """Generates a list of 'sed' commands that patch files in-place."""
    return [
        "sed --in-place --regexp-extended '{}' \"{}\"".format(regex, filename)
        for filename, regex in sorted(patch_map.items())
    ]
