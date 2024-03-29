"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "tiff"
VERSION = "4.2.0"
SHA256 = "eb0484e568ead8fa23b513e9b0041df7e327f4ee2d22db5a533929dfc19633cb"

URL = "https://download.osgeo.org/lib{name}/{name}-{version}.tar.gz"

STATIC_LIBS = [
    static_lib(NAME),
    static_lib(NAME + "xx"),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
