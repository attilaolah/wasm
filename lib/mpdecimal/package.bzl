"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.5.1"

URL = "https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-{version}.tar.gz"

SHA256 = "9f9cd4c041f99b5c49ffb7b59d9f12d95b683d88585608aa56a6307667b2b21f"

def download_mpdecimal():
    http_archive(
        name = "lib_mpdecimal",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "mpdecimal-{version}",
    )
