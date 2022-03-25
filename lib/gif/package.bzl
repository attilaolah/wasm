"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "5.2.1"

URL = "https://downloads.sourceforge.net/project/giflib/giflib-{version}.tar.gz"

SHA256 = "31da5562f44c5f15d63340a09a4fd62b48c45620cd302f77a6d9acf0077879bd"

def download():
    http_archive(
        name = "lib_gif",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "giflib-{version}",
    )
