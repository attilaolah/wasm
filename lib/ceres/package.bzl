"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "ceres"
VERSION = "2.1.0"
SHA256 = "ccbd716a93f65d4cb017e3090ae78809e02f5426dce16d0ee2b4f8a4ba2411a8"

URL = "https://github.com/{name}-solver/{name}-solver/archive/{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-solver-{version}",
    )
