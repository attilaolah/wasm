load("@rules_foreign_cc//tools/build_defs:cmake.bzl", "cmake_external")
load("//toolchains/make:configure.bzl", "make_commands", _lib_source = "lib_source")
load("//toolchains/make:env_vars.bzl", "ENV_VARS")

def cmake_lib(
        name,
        working_directory = "",
        cache_entries = None,
        lib_source = None,
        after_cmake = None,
        after_emcmake = None,
        linkopts = None,
        static_libraries = None,
        headers_only = False,
        deps = None,
        env = None):
    if cache_entries == None:
        cache_entries = {}
    if lib_source == None:
        lib_source = _lib_source(name)
    if linkopts == None:
        linkopts = ["-l{}".format(name)]
    if static_libraries == None:
        static_libraries = ["lib{}.a".format(name)]
    if env == None:
        env = {}
    wasm_env = dict(WASM_ENV_VARS.items() + env.items())

    cmake_external(
        name = name,
        cache_entries = cache_entries,
        env = select({
            "//conditions:default": env,
            "//config:wasm32": wasm_env,
            "//config:wasm64": wasm_env,
        }),
        headers_only = headers_only,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        linkopts = linkopts,
        make_commands = make_commands(
            before_make = after_cmake,
            before_emmake = after_emcmake,
        ),
        static_libraries = static_libraries,
        working_directory = working_directory,
        deps = deps or [],
    )
