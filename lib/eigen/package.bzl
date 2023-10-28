"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "eigen"
VERSION = "3.4.0"
SHA256 = "b4c198460eba6f28d34894e3a5710998818515104d6e74e5cc331ce31e46e626"

URL = "https://gitlab.com/lib{name}/{name}/-/archive/{version}/{name}-{version}.tar.bz2"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
