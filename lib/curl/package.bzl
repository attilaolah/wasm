"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "7.76.1"

URL = "https://curl.se/download/curl-{version}.tar.xz"

SHA256 = "64bb5288c39f0840c07d077e30d9052e1cbb9fa6c2dc52523824cc859e679145"

def download():
    http_archive(
        name = "lib_curl",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "curl-{version}",
    )
