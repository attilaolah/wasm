"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "8.0.1"

URL = "https://download.osgeo.org/proj/proj-{version}.tar.gz"

SHA256 = "e0463a8068898785ca75dd49a261d3d28b07d0a88f3b657e8e0089e16a0375fa"

def download():
    http_archive(
        name = "proj",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "proj-{version}",
    )
