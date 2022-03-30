"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "grass"
VERSION = "8.0.1"

URL = "https://{name}.osgeo.org/{name}{versionmmx}/source/{name}-{version}.tar.gz"

SHA256 = "e925bf8c44e1809459974457f2ab3c61dd5a24c0655ed026de665d1494f68a96"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = ["//lib/grass:grass.patch"],
    )
