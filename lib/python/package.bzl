"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.9.5"

URL = "https://www.python.org/ftp/python/{version}/Python-{version}.tar.xz"

SHA256 = "0c5a140665436ec3dbfbb79e2dfb6d192655f26ef4a29aeffcb6d1820d716d83"

def download():
    http_archive(
        name = "lib_python",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "Python-{version}",
    )
