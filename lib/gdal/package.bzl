"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "gdal"
VERSION = "3.5.2"

URLS = [
    "http://download.osgeo.org/{name}/{version}/{name}-{version}.tar.gz",
    "https://github.com/OSGeo/{name}/releases/download/v{version}/{name}-{version}.tar.gz",
]

SHA256 = "fbd696e1b2a858fbd2eb3718db16b14ed9ba82521d3578770d480c74fe1146d2"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = URLS,
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        # Workaround for https://github.com/OSGeo/gdal/issues/4815.
        patches = ["//lib/gdal:gdal.patch"],
    )
