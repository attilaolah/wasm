"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.4.19"

URL = "https://ftp.gnu.org/gnu/m4/m4-{version}.tar.xz"

SHA256 = "63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96"

def download():
    http_archive(
        name = "lib_m4",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "m4-{version}",
    )
