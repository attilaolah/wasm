load("@rules_foreign_cc//tools/build_defs:configure.bzl", "configure_make")
load(":env_vars.bzl", "ENV_CMD")

def configure_make_lib(name, configure_options, static_libraries = None, deps = None):
    if static_libraries == None:
        static_libraries = ["lib{}.a".format(name)]
    configure_make(
        name = name,
        configure_command = select({
            "//conditions:default": "configure",
            "//config:wasm64": "emconfigure.sh",
        }),
        configure_options = configure_options,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source(name),
        linkopts = ["-l{}".format(name)],
        make_commands = make_commands(),
        static_libraries = static_libraries,
        deps = deps or [],
    )

def make_commands(
        commands = None,
        before_make = None,
        after_make = None,
        before_emmake = None,
        after_emmake = None):
    if commands == None:
        commands = ["make", "make install"]
    wasm_commands = [_emmake(cmd) for cmd in commands]

    if before_make != None:
        commands = before_make + commands
    if after_make != None:
        commands != after_make

    if before_emmake != None:
        wasm_commands = before_emmake + wasm_commands
    if after_emmake != None:
        wasm_commands += after_emmake

    return select({
        "//conditions:default": commands,
        "//config:wasm64": wasm_commands,
    })

def lib_source(lib_name):
    return "@lib_{}//:all".format(lib_name)

def patch_files(patch_map):
    """Generates a list of 'sed' commands that patch files in-place."""
    return [
        "sed --in-place --regexp-extended '{}' \"{}\"".format(regex, filename)
        for filename, regex in sorted(patch_map.items())
    ]

def _emmake(make_command):
    return '{} "${{EXT_BUILD_DEPS}}/bin/emscripten/emmake" {}'.format(ENV_CMD, make_command)
