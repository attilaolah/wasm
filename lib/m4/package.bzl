"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "m4"
VERSION = "1.4.19"
SHA256 = "63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96"

URL = "https://ftp.gnu.org/gnu/{name}/{name}-{version}.tar.xz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
