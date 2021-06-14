"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.35.5"

URL = "https://www.sqlite.org/2021/sqlite-autoconf-3350500.tar.gz"

SHA256 = "f52b72a5c319c3e516ed7a92e123139a6e87af08a2dc43d7757724f6132e6db0"

def download_sqlite():
    http_archive(
        name = "lib_sqlite",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "sqlite-autoconf-3350500",
    )
