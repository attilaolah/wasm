"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "yasm"
VERSION = "1.3.0"
SHA256 = "3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f"

URL = "http://www.tortall.net/projects/{name}/releases/{name}-{version}.tar.gz"

BINARIES = [
    NAME,
    "vsyasm",
    "ytasm",
]

STATIC_LIBS = [static_lib(NAME, prefix = "liblib")]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
