"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.7"

URL = "https://github.com/ebiggers/libdeflate/archive/v{version}.tar.gz"

SHA256 = "a5e6a0a9ab69f40f0f59332106532ca76918977a974e7004977a9498e3f11350"

def download_deflate():
    http_archive(
        name = "lib_deflate",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libdeflate-{version}",
    )
