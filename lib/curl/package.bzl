"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "7.75.0"

URL = "https://curl.se/download/curl-{version}.tar.xz"

SHA256 = "fe0c49d8468249000bda75bcfdf9e30ff7e9a86d35f1a21f428d79c389d55675"

def download_curl():
    http_archive(
        name = "lib_curl",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "curl-{version}",
    )
