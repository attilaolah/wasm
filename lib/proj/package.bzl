"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "7.2.0"

URL = "https://download.osgeo.org/proj/proj-{version}.tar.gz"

SHA256 = "2957798e5fe295ff96a2af1889d0428e486363d210889422f76dd744f7885763"

def download_proj():
    http_archive(
        name = "lib_proj",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "proj-{version}",
    )
