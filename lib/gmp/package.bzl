"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "6.2.1"

URL = "https://gmplib.org/download/gmp/gmp-{version}.tar.xz"

SHA256 = "fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2"

def download():
    http_archive(
        name = "gmp",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "gmp-{version}",
    )
