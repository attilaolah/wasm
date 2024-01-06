"""Macro for building common SuiteSparse libraries."""

load("//toolchains/make:make.bzl", "lib_source", "make_lib")

PREFIX = "${EXT_BUILD_ROOT}/external/lib_suitesparse"

LIB_SOURCE = lib_source("suitesparse")

def suitesparse_lib(name, header_ext = "h", directory = None, deps = None, with_cuda = False, **kwargs):
    """Convenience macro that wraps make_lib().

    Args:
      name: Passed on to make_lib().
      header_ext: Used for locating header files to install.
      directory: Subdirectory containing the source files. Defaults to the name
        in upper case.
      deps: Passed on to make_lib().
      with_cuda: If True, set the CUDA=auto make variable during build.
      **kwargs: Passed on to make_lib().
    """
    if directory == None:
        directory = name.upper()
    if deps == None:
        deps = []
    deps.append(":config")

    prefix = "{}/{}".format(PREFIX, directory)

    cuda = "no"
    if with_cuda:
        cuda = "auto"

    make_lib(
        name = name,
        postfix_script = "\n".join([
            'install "{}/Include"/*.{} ${{INSTALLDIR}}/include'.format(prefix, header_ext),
            'install "{}/Lib"/*.a ${{INSTALLDIR}}/lib'.format(prefix),
        ]),
        lib_source = LIB_SOURCE,
        args = [
            '-C "{}"'.format(prefix),
            "CUDA={}".format(cuda),
        ],
        targets = ["static"],
        deps = deps,
        **kwargs
    )
