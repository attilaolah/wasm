load("@bazel_skylib//lib:collections.bzl", "collections")
load("//toolchains:utils.bzl", "ldflags")

_SED_CMD = """$(sed -i.orig -E '{sed_script}' "${{BUILD_TMPDIR}}/configure" >/dev/stderr)"""
_SED_LIBS = r"""s/LIBS="(-l{lib}\s+\$LIBS)"/LIBS="\1 {deps}"/"""
_SED_LIBVAR = r"""s/({libvar}="\${libvar} -l{lib} )"/\1 {deps}"/"""
_DIGITS = ''.join([str(c) for c in range(10)])

def fix_deps(transitive_deps):
    """Fixes transitive deps.

    Args:
      transitive_deps: Dict mapping libraries to a list of transitive deps.
    """
    libs_s = []
    libvar_s = []
    for lib, deps in transitive_deps.items():
        extra = ldflags(sorted(deps))
        libvar = '{}lib'.format(lib.rstrip(_DIGITS)).upper()
        libs_s.append(_SED_LIBS.format(lib = lib, deps = extra))
        libvar_s.append(_SED_LIBVAR.format(lib = lib, libvar = libvar, deps = extra))
    sed_script = "; ".join(libs_s + libvar_s)

    return _SED_CMD.format(sed_script = sed_script)
