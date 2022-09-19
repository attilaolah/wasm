"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "deflate"
VERSION = "1.14"

URL = "https://github.com/ebiggers/lib{name}/archive/v{version}.tar.gz"

SHA256 = "89e7df898c37c3427b0f39aadcf733731321a278771d20fc553f92da8d4808ac"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
    )
