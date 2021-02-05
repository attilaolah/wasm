"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.9.1"

URL = "https://www.python.org/ftp/{name}/{version}/Python-{version}.tar.xz"

SHA256 = "991c3f8ac97992f3d308fefeb03a64db462574eadbff34ce8bc5bb583d9903ff"

def download_python():
    http_archive(
        name = "python",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "Python-{version}",
    )
