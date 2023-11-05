"""Various utilities to modify source files and the build environment."""

def ldflags(libs):
    """Generates additional -llib for ldflags."""
    return " ".join(["-l{}".format(lib) for lib in libs])

def no_error(checks, join = True):
    """Ignore specific Clang check errors (treat them as warnings instead)."""
    args = ["-Wno-error={}".format(check) for check in checks]
    return " ".join(args) if join else args

def patch_files(patch_map):
    """Generates a list of 'sed' commands that patch files in-place."""
    return [
        "sed --in-place --regexp-extended '{}' \"{}\"".format(regex, filename)
        for filename, regex in sorted(patch_map.items())
    ]
