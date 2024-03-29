"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "ncurses"
VERSION = "6.2"
SHA256 = "30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d"

URL = "https://ftp.gnu.org/pub/gnu/{name}/{name}-{version}.tar.gz"

LIBS = [
    NAME,
    NAME + "++",
] + [
    # keep sorted
    "form",
    "menu",
    "panel",
    "tinfo",
]

STATIC_LIBS = [
    static_lib(lib)
    for lib in LIBS
] + [
    static_lib(lib + "_g")
    for lib in LIBS
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = ["//lib/ncurses:ncurses.patch"],
    )
