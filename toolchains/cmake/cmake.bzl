load("@rules_foreign_cc//tools/build_defs:cmake.bzl", "cmake_external")
load("//toolchains/make:configure.bzl", "lib_source", "make_commands")
load("//toolchains/make:env_vars.bzl", "ENV_VARS")

def cmake_lib(
        name,
        cache_entries,
        working_directory = "",
        after_cmake = None,
        after_emcmake = None,
        linkopts = None,
        static_libraries = None,
        headers_only = False,
        deps = None):
    if linkopts == None:
        linkopts = ["-l{}".format(name)]
    if static_libraries == None:
        static_libraries = ["lib{}.a".format(name)]
    cmake_external(
        name = name,
        cache_entries = cache_entries,
        env_vars = ENV_VARS,
        headers_only = headers_only,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source(name),
        linkopts = linkopts,
        make_commands = make_commands(
            before_make = after_cmake,
            before_emmake = after_emcmake,
        ),
        static_libraries = static_libraries,
        working_directory = working_directory,
        deps = deps or [],
    )
