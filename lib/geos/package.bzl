"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "geos"
VERSION = "3.9.1"

URL = "https://github.com/lib{name}/{name}/archive/{version}.tar.gz"

SHA256 = "e9e20e83572645ac2af0af523b40a404627ce74b3ec99727754391cdf5b23645"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
