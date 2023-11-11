"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "vpx"
VERSION = "1.13.1"
SHA256 = "00dae80465567272abd077f59355f95ac91d7809a2d3006f9ace2637dd429d14"

URL = "https://github.com/webmproject/lib{name}/archive/refs/tags/v{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
    )
