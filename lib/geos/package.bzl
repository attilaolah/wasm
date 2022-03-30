"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "geos"
VERSION = "3.10.2"

URL = "https://github.com/lib{name}/{name}/archive/{version}.tar.gz"

SHA256 = "d71932b444c9bd5d0bdf9eab4d22f25d9c31c122a73d619e2ec15294fb32147d"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
