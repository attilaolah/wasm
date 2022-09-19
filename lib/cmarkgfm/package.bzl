"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "cmarkgfm"
LNAME = "cmark-gfm"
VERSION = "0.29.0.gfm.6"

URL = "https://github.com/github/cmark-gfm/archive/refs/tags/{version}.tar.gz"

SHA256 = "b17d86164c0822b5db3818780b44cb130ff30e9c6ec6a64f199b6d142684dba0"

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
