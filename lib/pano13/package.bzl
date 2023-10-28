"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "pano13"
VERSION = "2.9.19"
SHA256 = "037357383978341dea8f572a5d2a0876c5ab0a83dffda431bd393357e91d95a8"

URL = "https://download.sourceforge.net/panotools/lib{name}-{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
        patches = [
            "//lib/pano13:CMakeLists.txt.patch",
        ],
    )
