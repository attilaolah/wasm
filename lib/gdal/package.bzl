"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "gdal"
VERSION = "3.2.1"

URL = "https://github.com/OSGeo/{name}/releases/download/v{version}/{name}-{version}.tar.gz"

SHA256 = "43d40ba940e3927e38f9e98062ff62f9fa993ceade82f26f16fab7e73edb572e"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
