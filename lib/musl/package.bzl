"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.2.2"

URL = "https://musl.libc.org/releases/musl-{version}.tar.gz"

SHA256 = "9b969322012d796dc23dda27a35866034fa67d8fb67e0e2c45c913c3d43219dd"

def download_musl():
    http_archive(
        name = "lib_musl",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "musl-{version}",
    )
