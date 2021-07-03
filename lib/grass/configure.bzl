load("//toolchains:utils.bzl", "ldflags")

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
