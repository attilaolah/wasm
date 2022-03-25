"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "2.9.19"

URL = "https://download.sourceforge.net/panotools/libpano13-{version}.tar.gz"

SHA256 = "037357383978341dea8f572a5d2a0876c5ab0a83dffda431bd393357e91d95a8"

def download():
    http_archive(
        name = "pano13",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libpano13-{version}",
        patches = [
            "//lib/pano13:CMakeLists.txt.patch",
        ],
    )
