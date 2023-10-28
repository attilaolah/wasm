"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "major", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "sdl"
VERSION = "2.24.0"
SHA256 = "91e4c34b1768f92d399b078e171448c6af18cafda743987ed2064a28954d6d97"

URL = "https://www.lib{name}.org/release/{uname}{versionm}-{version}.tar.gz"

STATIC_LIBS = [
    static_lib(NAME.upper() + major(VERSION)),
    static_lib(NAME.upper() + major(VERSION) + "main"),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{uname}{versionm}-{version}",
    )
