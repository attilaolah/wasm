"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "gdal"
VERSION = "3.4.2"

URLS = [
    "http://download.osgeo.org/{name}/{version}/{name}-{version}.tar.gz",
    "https://github.com/OSGeo/{name}/releases/download/v{version}/{name}-{version}.tar.gz"
]

SHA256 = "7edef6de47c67da806b74eb8d3a20550933392a295c707682ea21b72123e34ce"

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
