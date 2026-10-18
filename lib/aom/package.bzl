"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "aom"
VERSION = "3.8.0"
SHA256 = "d8e0cb0157410e97ffcf01f4fe24e6447303c46cc4103d6597ba30ef508afe05"

URL = "https://github.com/m-ab-s/{name}/archive/refs/tags/v{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
