load("//toolchains/make:configure.bzl", "lib_source")
load("//toolchains/make:make.bzl", "make_lib")

PREFIX = "${EXT_BUILD_ROOT}/external/lib_suite_sparse"

LIB_SOURCE = lib_source("suite_sparse")

def suite_sparse_lib(name, header_ext = "h", directory = None, deps = None):
    if directory == None:
        directory = name.upper()
    if deps == None:
        deps = []

    prefix = "{}/{}".format(PREFIX, directory)

    make_lib(
        name = name,
        install_commands = [
            'install "{}/Include"/*.{} ${{INSTALLDIR}}/include'.format(prefix, header_ext),
            'install "{}/Lib"/*.a ${{INSTALLDIR}}/lib'.format(prefix),
        ],
        lib_source = LIB_SOURCE,
        make_commands = [
            'make -C "{}" static'.format(prefix),
        ],
        deps = deps,
    )
