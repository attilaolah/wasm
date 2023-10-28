"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "bz2"
VERSION = "1.0.8"
SHA256 = "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"

URL = "https://sourceware.org/pub/bzip2/bzip2-{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "bzip2-{version}",
        patches = ["//lib/bz2:bz2.patch"],
    )
