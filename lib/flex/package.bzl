"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.6.4"

URL = "https://github.com/westes/flex/releases/download/v{version}/flex-{version}.tar.gz"

SHA256 = "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995"

def download_flex():
    http_archive(
        name = "lib_flex",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "flex-{version}",
    )
