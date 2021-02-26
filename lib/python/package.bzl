"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.9.2"

URL = "https://www.python.org/ftp/python/{version}/Python-{version}.tar.xz"

SHA256 = "3c2034c54f811448f516668dce09d24008a0716c3a794dd8639b5388cbde247d"

def download_python():
    http_archive(
        name = "lib_python",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "Python-{version}",
    )
