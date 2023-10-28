"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "dep_spec", "library_path", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "jpegturbo"
VERSION = "2.1.0"
SHA256 = "d6b7790927d658108dfd3bee2f0c66a2924c51ee7f9dc930f62c452f4a638c52"

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
