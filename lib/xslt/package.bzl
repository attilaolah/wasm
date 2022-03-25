"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.1.34"

URL = "http://xmlsoft.org/sources/libxslt-{version}.tar.gz"

SHA256 = "98b1bd46d6792925ad2dfe9a87452ea2adebf69dcb9919ffd55bf926a7f93f7f"

def download():
    http_archive(
        name = "lib_xslt",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libxslt-{version}",
    )
