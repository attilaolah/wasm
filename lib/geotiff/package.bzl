"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.6.0"

URL = "https://github.com/OSGeo/libgeotiff/releases/download/{version}/libgeotiff-{version}.tar.gz"

SHA256 = "9311017e5284cffb86f2c7b7a9df1fb5ebcdc61c30468fb2e6bca36e4272ebca"

def download():
    http_archive(
        name = "lib_geotiff",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libgeotiff-{version}",
    )
