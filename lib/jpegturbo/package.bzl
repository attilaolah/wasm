"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.1.0"

URL = "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/{version}.tar.gz"

SHA256 = "d6b7790927d658108dfd3bee2f0c66a2924c51ee7f9dc930f62c452f4a638c52"

def download_jpegturbo():
    http_archive(
        name = "lib_jpegturbo",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libjpeg-turbo-{version}",
    )
