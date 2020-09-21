load("@rules_foreign_cc//tools/build_defs:configure.bzl", "configure_make")
load(":env_vars.bzl", "ENV_CMD")

def configure_make_lib(name, configure_options, static_libraries = None, deps = None):
    if static_libraries == None:
        static_libraries = ["lib{}.a".format(name)]
    configure_make(
        name = name,
        configure_command = configure_command(),
        configure_options = configure_options,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source(name),
        linkopts = ["-l{}".format(name)],
        make_commands = make_commands(),
        static_libraries = static_libraries,
        deps = deps or [],
    )

def configure_make_binaries(name, lib_name, binaries, configure_options, deps = None):
    configure_make(
        name = name,
        binaries = binaries,
        configure_command = configure_command(),
        configure_options = configure_options,
        lib_name = "{}_bin".format(lib_name),
        lib_source = lib_source(lib_name),
        make_commands = make_commands(),
        deps = deps or [],
    )

def configure_command():
    return select({
        "//conditions:default": "configure",
        "//config:wasm64": "emconfigure.sh",
    })

def make_commands(commands = None):
    if commands == None:
        commands = ["make", "make install"]

    return select({
        "//conditions:default": commands,
        "//config:wasm64": [emmake(cmd) for cmd in commands],
    })

def lib_source(lib_name):
    return "@lib_{}//:all".format(lib_name)

def emmake(make_command):
    return '{} "${{EXT_BUILD_DEPS}}/bin/emscripten/emmake" {}'.format(ENV_CMD, make_command)
