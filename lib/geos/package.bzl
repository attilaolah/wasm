"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.9.1"

URL = "https://github.com/libgeos/geos/archive/{version}.tar.gz"

SHA256 = "e9e20e83572645ac2af0af523b40a404627ce74b3ec99727754391cdf5b23645"

def download():
    http_archive(
        name = "lib_geos",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "geos-{version}",
    )
