"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "6.9.6"

URL = "https://github.com/kkos/oniguruma/releases/download/v{version}/onig-{version}.tar.gz"

SHA256 = "bd0faeb887f748193282848d01ec2dad8943b5dfcb8dc03ed52dcc963549e819"

def download():
    http_archive(
        name = "oniguruma",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "onig-{version}",
    )
