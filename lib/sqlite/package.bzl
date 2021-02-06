"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.34.1"

URL = "https://www.sqlite.org/2021/sqlite-autoconf-3340100.tar.gz"

SHA256 = "2a3bca581117b3b88e5361d0ef3803ba6d8da604b1c1a47d902ef785c1b53e89"

def download_sqlite():
    http_archive(
        name = "lib_sqlite",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "sqlite-autoconf-3340100",
    )
