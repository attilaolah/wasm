load("//toolchains:utils.bzl", "ldflags")
load("//lib:defs.bzl", "include_dir", "library_dir")

_SED_CMD = """$(sed -i.orig -E '{sed_script}' "${{BUILD_TMPDIR}}/configure" >/dev/stderr)"""
_S_LIBS = r"""s/LIBS="(-l{lib}\s+\$LIBS)"/LIBS="\1 {deps}"/"""
_S_LIBVAR = r"""s/({libvar}="\${libvar} -l{lib} )"/\1 {deps}"/"""
_DIGITS = "".join([str(c) for c in range(10)])

def configure_sed(transitive_deps, cross_compiling = False):
    """Patches the configure script.

    Args:
      transitive_deps: Dict mapping libraries to a list of transitive deps.
      cross_compiling: Enables cross-compilation in the configure script.
    """
    sed_e = []
    for lib, deps in transitive_deps.items():
        extra = ldflags(sorted(deps))
        libvar = "{}lib".format(lib.rstrip(_DIGITS)).upper()
        sed_e += [
            _S_LIBS.format(lib = lib, deps = extra),
            _S_LIBVAR.format(lib = lib, libvar = libvar, deps = extra),
        ]
    if cross_compiling:
        sed_e.append("s/ac_cv_prog_cc_cross=no/ac_cv_prog_cc_cross=yes/")
    sed_script = "; ".join(sed_e)

    return _SED_CMD.format(sed_script = sed_script)

def with_features(*features):
    return ["--with-{}".format(feature) for feature in features]

def without_features(*features):
    return ["--without-{}".format(feature) for feature in features]

def with_libraries(*features, **libraries):
    flags = []
    for feature in features:
        flags += _with_library(feature)
    for feature, library in libraries.items():
        flags += _with_library(feature, library)
    return flags

def _with_library(feature, library = None):
    return with_features(feature) + [
        '--with-{}-includes="{}"'.format(feature, include_dir(library or feature)),
        '--with-{}-libs="{}"'.format(feature, library_dir(library or feature)),
    ]
