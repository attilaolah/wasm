"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "cmarkgfm"
LNAME = "cmark-gfm"
VERSION = "0.29.0.gfm.3"

URL = "https://github.com/github/cmark-gfm/archive/refs/tags/{version}.tar.gz"

SHA256 = "56fba15e63676c756566743dcd43c61c6a77cc1d17ad8be88a56452276ba4d4c"

STATIC_LIBS = [
    static_lib(LNAME),
    static_lib(LNAME + "-extensions"),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = LNAME + "-{version}",
    )
