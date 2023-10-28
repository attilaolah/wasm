"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "quirc"
VERSION = "1.0.1"
SHA256 = "637e3dd297e44268f90d331e0fbf9a6a154d5873b806328d502e87802af35627"

URL = "https://github.com/evolation/lib{name}/archive/refs/tags/{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
    )
