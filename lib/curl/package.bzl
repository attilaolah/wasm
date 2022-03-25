"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "curl"
VERSION = "7.76.1"

URL = "https://{name}.se/download/{name}-{version}.tar.xz"

SHA256 = "64bb5288c39f0840c07d077e30d9052e1cbb9fa6c2dc52523824cc859e679145"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
