"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.2.1"

URL = "https://github.com/OSGeo/gdal/releases/download/v{version}/gdal-{version}.tar.gz"

SHA256 = "43d40ba940e3927e38f9e98062ff62f9fa993ceade82f26f16fab7e73edb572e"

def download():
    http_archive(
        name = "lib_gdal",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "gdal-{version}",
    )
