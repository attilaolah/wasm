"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "cmark"
VERSION = "0.30.2"
SHA256 = "6c7d2bcaea1433d977d8fed0b55b71c9d045a7cdf616e3cd2dce9007da753db3"

URL = "https://github.com/commonmark/{name}/archive/refs/tags/{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
