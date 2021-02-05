"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.2.2"

URL = "https://github.com/gflags/gflags/archive/v{version}.tar.gz"

SHA256 = "34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf"

def download_gflags():
    http_archive(
        name = "lib_gflags",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "gflags-{version}",
    )
