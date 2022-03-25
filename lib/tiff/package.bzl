"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "4.2.0"

URL = "https://download.osgeo.org/libtiff/tiff-{version}.tar.gz"

SHA256 = "eb0484e568ead8fa23b513e9b0041df7e327f4ee2d22db5a533929dfc19633cb"

def download():
    http_archive(
        name = "tiff",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "tiff-{version}",
    )
