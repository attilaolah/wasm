"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "expat"
VERSION = "2.2.10"
SHA256 = "5dfe538f8b5b63f03e98edac520d7d9a6a4d22e482e5c96d4d06fcc5485c25f2"

URL = "https://github.com/lib{name}/lib{name}/releases/download/R_{version_}/{name}-{version}.tar.xz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
