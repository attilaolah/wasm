"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "2.2.10"

URL = "https://github.com/libexpat/libexpat/releases/download/R_{version_}/expat-{version}.tar.xz"

SHA256 = "5dfe538f8b5b63f03e98edac520d7d9a6a4d22e482e5c96d4d06fcc5485c25f2"

def download():
    http_archive(
        name = "expat",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "expat-{version}",
    )
