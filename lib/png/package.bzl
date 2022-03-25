"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "1.6.37"

URL = "https://downloads.sourceforge.net/libpng/libpng-{version}.tar.gz"

SHA256 = "daeb2620d829575513e35fecc83f0d3791a620b9b93d800b763542ece9390fb4"

def download():
    http_archive(
        name = "png",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libpng-{version}",
    )
