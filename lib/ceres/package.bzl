"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "1.14.0"

URL = "https://github.com/ceres-solver/ceres-solver/archive/{version}.tar.gz"

SHA256 = "1296330fcf1e09e6c2f926301916f64d4a4c5c0ff12d460a9bc5d4c48411518f"

def download():
    http_archive(
        name = "ceres",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "ceres-solver-{version}",
    )
