"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "exiv2"
VERSION = "0.27.5"

URL = "https://github.com/{tname}/{name}/releases/download/v{version}/{name}-{version}-Source.tar.gz"

SHA256 = "35a58618ab236a901ca4928b0ad8b31007ebdc0386d904409d825024e45ea6e2"

STATIC_LIBS = [
    static_lib(NAME),
    static_lib(NAME + "-xmp"),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}-Source",
    )
