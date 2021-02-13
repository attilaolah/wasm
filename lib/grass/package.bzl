"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "7.8.5"

URL = "https://grass.osgeo.org/grass78/source/grass-{version}.tar.gz"

SHA256 = "a359bb665524ecccb643335d70f5436b1c84ffb6a0e428b78dffebacd983ff37"

def download_grass():
    http_archive(
        name = "lib_grass",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "grass-{version}",
    )
