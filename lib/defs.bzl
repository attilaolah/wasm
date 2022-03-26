load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("//tools:version_info.bzl", "version_info")

# Common prefix for all dependencies:
EXT_BUILD_DEPS = "${EXT_BUILD_DEPS}"

def lib_package(version_url = None, version_regex = None):
    """Common package contents for most packages under //lib."""
    bzl_library(
        name = "package",
        srcs = ["package.bzl"],
        deps = [
            "//lib:defs",
            "//lib:http_archive",
        ],
    )
    if version_url != None and version_regex != None:
        version_info(
            version_url = version_url,
            version_regex = version_regex,
        )

def lib_name(library):
    """Generate a consistent library name."""
    return "{library}_lib".format(library = library)

def repo_name(library):
    """Generate a consintent repository name."""
    return "lib_{library}".format(library = library)

def static_lib(library):
    """Generate the static library name."""
    return "lib{library}.a".format(library = library)

def include_dir(library, extra_dirs = None):
    return "/".join([
        EXT_BUILD_DEPS,
        lib_name(library),
        "include",
    ] + (extra_dirs or []))

def library_dir(library):
    return "/".join((
        EXT_BUILD_DEPS,
        lib_name(library),
        "lib",
    ))

def library_path(library, static_lib_name = None):
    return "/".join((
        library_dir(library),
        static_lib(static_lib_name or library),
    ))

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
