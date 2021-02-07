"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.1.1i"

URL = "https://www.openssl.org/source/openssl-{version}.tar.gz"

SHA256 = "e8be6a35fe41d10603c3cc635e93289ed00bf34b79671a3a4de64fcee00d5242"

def download_open_ssl():
    http_archive(
        name = "lib_open_ssl",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "openssl-{version}",
    )
