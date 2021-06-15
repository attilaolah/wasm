"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.7.6"

URL = "https://ftp.gnu.org/gnu/bison/bison-{version}.tar.xz"

SHA256 = "67d68ce1e22192050525643fc0a7a22297576682bef6a5c51446903f5aeef3cf"

def download_bison():
    http_archive(
        name = "lib_bison",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "bison-{version}",
    )
