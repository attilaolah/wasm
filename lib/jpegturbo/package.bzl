"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "dep_spec", "library_path", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "jpegturbo"
VERSION = "3.0.1"
SHA256 = "5b9bbca2b2a87c6632c821799438d358e27004ab528abf798533c15d50b39f82"

URL = "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/{version}.tar.gz"

INAME = "jpeg"
LNAME = "turbojpeg"

STATIC_LIBS = [static_lib(lib) for lib in (INAME, LNAME)]

SPEC = dep_spec(
    name = NAME,
    library = library_path(NAME, STATIC_LIBS[0]),
)

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libjpeg-turbo-{version}",
    )
