"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.1.1k"

URL = "https://www.openssl.org/source/openssl-{version}.tar.gz"

SHA256 = "892a0875b9872acd04a9fde79b1f943075d5ea162415de3047c327df33fbaee5"

def download():
    http_archive(
        name = "lib_openssl",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "openssl-{version}",
    )
