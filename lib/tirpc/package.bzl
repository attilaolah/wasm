"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "tirpc"
VERSION = "1.3.1"

URL = "https://downloads.sourceforge.net/project/lib{name}/lib{name}/{version}/lib{name}-{version}.tar.bz2"

SHA256 = "245895caf066bec5e3d4375942c8cb4366adad184c29c618d97f724ea309ee17"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
    )
