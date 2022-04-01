# Common prefix for all dependencies:
EXT_BUILD_DEPS = "${EXT_BUILD_DEPS}"
EXT_BUILD_ROOT = "${EXT_BUILD_ROOT}"

def lib_name(library):
    """Generate a consistent library name."""
    return "{library}_lib".format(library = library)

def repo_name(library):
    """Generate a consintent repository name."""
    return "lib_{library}".format(library = library)

def static_lib(library):
    """Generate the static library name."""
    return "lib{library}.a".format(library = library)

def root_path(path, double_escape = False):
    return "/".join([
        ("$" if double_escape else "") + EXT_BUILD_ROOT,
        path,
    ])

def dep_path(library, subpath = "", double_escape = False):
    return "/".join([
        ("$" if double_escape else "") + EXT_BUILD_DEPS,
        lib_name(library),
    ]) + subpath

def runtime_path(deps, double_escape = True):
    return ":".join([
        root_path("$(execpaths {})/bin".format(dep), double_escape)
        for dep in deps
    ] + [
        "$${PATH}" if double_escape else "${PATH}",
    ])

def include_dir(library, subdir = ""):
    subpath = "/include"
    if subdir:
        subpath += "/" + subdir
    return dep_path(library, subpath)

def library_dir(library):
    return dep_path(library, "/lib")

def library_path(library, static_lib = None):
    return "/".join([
        library_dir(library),
        static_lib or _static_lib(library),
    ])

def include_flags(include_dir):
    return "-I{include_dir}".format(include_dir = include_dir)

def link_flags(lib_name, lib_dir = None):
    return " ".join((
        "-L{lib_dir}".format(lib_dir = lib_dir or library_dir(lib_name)),
        link_opt(lib_name),
    ))

def link_opt(lib_name):
    return "-l{lib_name}".format(lib_name = lib_name)

def major(version, delimiter = "."):
    """Extract the major version."""
    return version.split(delimiter)[0]

def major_minor(version, join = ".", delimiter = "."):
    """Extract major & minor versions, joined by the given delimiter."""
    return join.join(version.split(delimiter)[:2])

def dep_spec(name, include_dir = None, library = None, exclude = ()):
    spec = {
        "include_dir": include_dir or _include_dir(name),
        "library": library or _library_path(name),
        "name": name,
    }
    for item in exclude:
        spec.pop(item)
    return spec

def make_args(sort_keys = True, **kwargs):
    """Convenience macro for constructing the make_args list."""
    result = ['{}="{}"'.format(key.upper(), val) for key, val in kwargs.items()]

    if sort_keys:
        result = sorted(result)

    return result

_include_dir = include_dir
_library_path = library_path
_static_lib = static_lib
