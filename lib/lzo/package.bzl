"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "lzo"
VERSION = "2.10"

URL = "https://www.oberhumer.com/opensource/{name}/download/{name}-{version}.tar.gz"

SHA256 = "c0f892943208266f9b6543b3ae308fab6284c5c90e627931446fb49b4221a072"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
