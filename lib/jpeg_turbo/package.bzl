"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.0.4"

URL = "https://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-{version}.tar.gz"

SHA256 = "33dd8547efd5543639e890efbf2ef52d5a21df81faf41bb940657af916a23406"

def download_jpeg_turbo():
    http_archive(
        name = "lib_jpeg_turbo",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libjpeg-turbo-{version}",
    )
