"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "z"
VERSION = "1.3"
SHA256 = "8a9ba2898e1d0d774eca6ba5b4627a11e5588ba85c8851336eb38de4683050a7"

URL = "https://www.zlib.net/{name}lib-{version}.tar.xz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}lib-{version}",
    )
