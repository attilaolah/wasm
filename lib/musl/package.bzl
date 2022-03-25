"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "musl"
VERSION = "1.2.2"

URL = "https://{name}.libc.org/releases/{name}-{version}.tar.gz"

SHA256 = "9b969322012d796dc23dda27a35866034fa67d8fb67e0e2c45c913c3d43219dd"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
