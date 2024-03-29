"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "gflags"
VERSION = "2.2.2"
SHA256 = "34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf"

URL = "https://github.com/{name}/{name}/archive/v{version}.tar.gz"

STATIC_LIBS = [
    static_lib(NAME),
    static_lib(NAME + "_nothreads"),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
