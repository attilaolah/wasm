"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "z"
VERSION = "1.2.11"
SHA256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1"

URL = "https://downloads.sourceforge.net/libpng/{name}lib-{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}lib-{version}",
    )
