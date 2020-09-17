load(":configure.bzl", _make_commands = "make_commands")

def make_commands(lib_name):
    return _make_commands(commands = [
        'make -C "${EXT_BUILD_ROOT}/external/lib_{}"'.format(lib_name),
        'make -C "${EXT_BUILD_ROOT}/external/lib_{}" install PREFIX="${INSTALLDIR}"'.format(lib_name),
    ])
