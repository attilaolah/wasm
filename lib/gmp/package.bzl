"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "gmp"
VERSION = "6.2.1"

URL = "https://{name}lib.org/download/{name}/{name}-{version}.tar.xz"

SHA256 = "fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
