"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.4.0"

URL = "https://github.com/uclouvain/openjpeg/archive/v{version}.tar.gz"

SHA256 = "8702ba68b442657f11aaeb2b338443ca8d5fb95b0d845757968a7be31ef7f16d"

def download_openjpeg():
    http_archive(
        name = "lib_openjpeg",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "openjpeg-{version}",
    )
