"""Various utilities to modify source files and the build environment."""

def ldflags(libs):
    """Generates additional -llib for ldflags."""
    return " ".join(["-l{}".format(lib) for lib in libs])

def no_error(checks):
    """Ignore specific Clang check errors (treat them as warnings instead)."""
    return " ".join(["-Wno-error={}".format(check) for check in checks])

def patch_files(patch_map):
    """Generates a list of 'sed' commands that patch files in-place."""
    return [
        "sed --in-place --regexp-extended '{}' \"{}\"".format(regex, filename)
        for filename, regex in sorted(patch_map.items())
    ]

def path(prefixes, existing = "${PATH}", suffixes = None):
    """Construct a ${PATH} env var with additional prefixes."""
    return ":".join(prefixes + [existing] + (suffixes or []))
