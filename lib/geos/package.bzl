"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "geos"
VERSION = "3.11.0"

URL = "https://github.com/lib{name}/{name}/archive/{version}.tar.gz"

SHA256 = "c7a06d4ff235e768900e8a5c30dc1b8f7511587c77c548df068ca96080abe8c6"

STATIC_LIBS = [
    static_lib(NAME),
    static_lib(NAME + "_c"),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
