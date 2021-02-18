"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "68.2"

URL = "https://github.com/unicode-org/icu/releases/download/release-{version-}/icu4c-{version_}-src.tgz"

SHA256 = "c79193dee3907a2199b8296a93b52c5cb74332c26f3d167269487680d479d625"

def download_icu():
    http_archive(
        name = "lib_icu",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "icu",
    )
