load("@rules_foreign_cc//tools/build_defs:make.bzl", "make")
load(":configure.bzl", "lib_source", "make_commands")

def make_lib(name):
    make(
        name = name,
        lib_name = "{}_lib".format(name),
        lib_source = lib_source(name),
        linkopts = ["-l{}".format(name)],
        make_commands = [
            'make -C "${{EXT_BUILD_ROOT}}/external/lib_{}"'.format(name),
            'make -C "${{EXT_BUILD_ROOT}}/external/lib_{}" install PREFIX="${{INSTALLDIR}}"'.format(name),
        ],
        static_libraries = ["lib{}.a".format(name)],
    )
