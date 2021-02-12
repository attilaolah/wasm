"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.1.1"

URL = "https://support.hdfgroup.org/ftp/lib-external/szip/{version}/src/szip-{version}.tar.gz"

SHA256 = "21ee958b4f2d4be2c9cabfa5e1a94877043609ce86fde5f286f105f7ff84d412"

def download_szip():
    http_archive(
        name = "lib_szip",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "szip-{version}",
    )
