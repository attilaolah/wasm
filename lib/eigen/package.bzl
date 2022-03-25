"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "3.3.9"

URL = "https://gitlab.com/libeigen/eigen/-/archive/{version}/eigen-{version}.tar.bz2"

SHA256 = "0fa5cafe78f66d2b501b43016858070d52ba47bd9b1016b0165a7b8e04675677"

def download():
    http_archive(
        name = "eigen",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "eigen-{version}",
    )
