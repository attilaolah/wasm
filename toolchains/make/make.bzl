"""Make library macro.

Contains a convenience macro that wraps make() from @rules_foreign_cc.
"""

load("@bazel_skylib//lib:collections.bzl", "collections")
load("@rules_foreign_cc//foreign_cc:make.bzl", "make")
load("//lib:defs.bzl", "repo_name")
load("//tools/archive_symbols:archive_symbols.bzl", "archive_symbols")

EM_ENV = {
    # NodeJS cross-compiling emulator. Required for some CMake builds.
    "CROSSCOMPILING_EMULATOR": "$(execpath @nodejs//:node)",

    # Emscripten: Use local cache.
    "EM_CACHE": "$${EXT_BUILD_ROOT}/.em_cache",
}

EM_TOOLS = [
    "@nodejs//:node",
    "@python3//:python",
    "@emscripten//:emmake",
    "@emscripten//:bin",
]

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
            "//cond:emscripten": dict(env),
            "//conditions:default": dict(env),
        }
    emscripten_env(env["//cond:emscripten"])

    make(
        name = name,
        env = select(env),
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        build_data = _build_data(build_data),
        tool_prefix = select({
            "//cond:emscripten": " ".join([
                "EM_PKG_CONFIG_PATH=$${PKG_CONFIG_PATH:-}",
                "$(execpath @emscripten//:emmake)",
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

def emscripten_env(env):
    """Set Emscripten environment variables."""
    env.update(EM_ENV)

def build_data(extras = None, em_tools = None):
    """Extends build_data with extras.

    For Emscripten, merges extras with EM_TOOLS. Otherwise it simply selects
    extras for build_data.

    Args:
      extras: Existing build_data to extend.
      em_tools: Additional tools to append for wasm builds.

    Returns:
      A select() wrapping the resulting build_data.
    """
    if extras == None:
        extras = []

    if em_tools == None:
        em_tools = []

    if type(extras) != type({}):
        extras = {
            "//conditions:default": extras,
            "//cond:emscripten": extras,
        }
    extras.setdefault("//cond:emscripten", [])
    extras["//cond:emscripten"] = collections.uniq(EM_TOOLS + extras["//cond:emscripten"] + em_tools)

    return select(extras)

_build_data = build_data

def lib_source(lib_name):
    return "@{}//:all".format(repo_name(lib_name))

_lib_source = lib_source
