"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "grass"
VERSION = "7.8.5"

URL = "https://{name}.osgeo.org/{name}{versionmmx}/source/{name}-{version}.tar.gz"

SHA256 = "a359bb665524ecccb643335d70f5436b1c84ffb6a0e428b78dffebacd983ff37"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = ["//lib/grass:grass.patch"],
    )
