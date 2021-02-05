"""Make library macro.

Contains a convenience macro that wraps make() from @rules_foreign_cc.
"""

load("@rules_foreign_cc//tools/build_defs:make.bzl", "make")
load(":configure.bzl", "TOOLS_DEPS", "WASM_ENV_VARS", _lib_source = "lib_source", _make_commands = "make_commands")

def make_lib(
        name,
        lib_source = None,
        make_commands = None,
        install_commands = None,
        linkopts = None,
        static_libraries = None,
        deps = None,
        env = None):
    if lib_source == None:
        lib_source = _lib_source(name)
    if make_commands == None:
        make_commands = [
            'make -C "${{EXT_BUILD_ROOT}}/external/lib_{}"'.format(name),
            'make -C "${{EXT_BUILD_ROOT}}/external/lib_{}" install PREFIX="${{INSTALLDIR}}"'.format(name),
        ]
    if linkopts == None:
        linkopts = ["-l{}".format(name)]
    if static_libraries == None:
        static_libraries = ["lib{}.a".format(name)]
    if deps == None:
        deps = []
    if env == None:
        env = {}
    wasm_env = dict(WASM_ENV_VARS.items() + env.items())

    make(
        name = name,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source,
        linkopts = linkopts,
        make_commands = _make_commands(
            commands = make_commands,
            after_make = install_commands,
            after_emmake = install_commands,
        ),
        env = select({
            "//conditions:default": env,
            "//config:wasm32": wasm_env,
            "//config:wasm64": wasm_env,
        }),
        static_libraries = static_libraries,
        deps = deps,
        tools_deps = TOOLS_DEPS,
    )
