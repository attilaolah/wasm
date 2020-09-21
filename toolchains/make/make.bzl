load("@rules_foreign_cc//tools/build_defs:make.bzl", "make")
load(":configure.bzl", "lib_source", "make_commands")

def make_lib(name):
    make(
        name = name,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source(name),
        linkopts = ["-l{}".format(name)],
        make_commands = _make_commands(name),
        static_libraries = ["lib{}.a".format(name)],
    )

def make_binaries(name, lib_name, binaries):
    make(
        name = name,
        binaries = binaries,
        lib_name = "{}_bin".format(lib_name),
        lib_source = lib_source(lib_name),
        make_commands = _make_commands(lib_name),
    )

def _make_commands(lib_name):
    return make_commands([
        'make -C "${{EXT_BUILD_ROOT}}/external/lib_{}"'.format(lib_name),
        'make -C "${{EXT_BUILD_ROOT}}/external/lib_{}" install PREFIX="${{INSTALLDIR}}"'.format(lib_name),
    ])
