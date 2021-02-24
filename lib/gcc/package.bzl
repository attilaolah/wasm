"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "10.2.0"

URLS = [
    "https://ftp.gnu.org/gnu/gcc/gcc-{version}/gcc-{version}.tar.xz",
    "https://mirror.kumi.systems/gnu/gcc/gcc-{version}/gcc-{version}.tar.xz",
]

SHA256 = "b8dd4368bb9c7f0b98188317ee0254dd8cc99d1e3a18d0ff146c855fe16c1d8c"

def download_gcc():
    http_archive(
        name = "lib_gcc",
        version = VERSION,
        urls = URLS,
        sha256 = SHA256,
        strip_prefix = "gcc-{version}",
    )
