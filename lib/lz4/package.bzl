"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "1.9.3"

URL = "https://github.com/lz4/lz4/archive/v{version}.tar.gz"

SHA256 = "030644df4611007ff7dc962d981f390361e6c97a34e5cbc393ddfbe019ffe2c1"

def download():
    http_archive(
        name = "lz4",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lz4-{version}",
    )
