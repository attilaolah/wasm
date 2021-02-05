"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.3.8-rc1"

URL = "https://gitlab.com/libeigen/eigen/-/archive/{version}/eigen-{version}.tar.bz2"

SHA256 = "2922184d9501eb2a005c9b9df9e1f809696a84d49ca1942dab95390f3b9c4fec"

def download_eigen():
    http_archive(
        name = "lib_eigen",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "eigen-{version}",
    )
