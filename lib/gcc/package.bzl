"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "gcc"
VERSION = "10.2.0"
SHA256 = "b8dd4368bb9c7f0b98188317ee0254dd8cc99d1e3a18d0ff146c855fe16c1d8c"

URLS = [
    "https://ftp.gnu.org/gnu/{name}/{name}-{version}/{name}-{version}.tar.xz",
    "https://mirror.kumi.systems/gnu/{name}/{name}-{version}/{name}-{version}.tar.xz",
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = URLS,
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
