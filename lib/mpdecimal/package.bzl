"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "mpdecimal"
VERSION = "2.5.1"

URL = "https://www.bytereef.org/software/{name}/releases/{name}-{version}.tar.gz"

SHA256 = "9f9cd4c041f99b5c49ffb7b59d9f12d95b683d88585608aa56a6307667b2b21f"

STATIC_LIBS = [
    static_lib(NAME[:5]),
    static_lib(NAME[:5] + "++"),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
