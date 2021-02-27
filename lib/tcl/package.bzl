"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "8.6.11"

MAJOR_MINOR = ".".join(VERSION.split(".")[:2])

URL = "https://downloads.sourceforge.net/tcl/tcl{version}-src.tar.gz"

SHA256 = "8c0486668586672c5693d7d95817cb05a18c5ecca2f40e2836b9578064088258"

def download_tcl():
    http_archive(
        name = "lib_tcl",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "tcl{version}",
    )
