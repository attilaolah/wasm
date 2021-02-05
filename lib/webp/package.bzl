"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.1.0"

URL = "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-{version}.tar.gz"

SHA256 = "98a052268cc4d5ece27f76572a7f50293f439c17a98e67c4ea0c7ed6f50ef043"

def download_webp():
    http_archive(
        name = "lib_webp",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libwebp-{version}",
    )
