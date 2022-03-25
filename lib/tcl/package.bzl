"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "tcl"
VERSION = "8.6.11"

URL = "https://downloads.sourceforge.net/{name}/{name}{version}-src.tar.gz"

SHA256 = "8c0486668586672c5693d7d95817cb05a18c5ecca2f40e2836b9578064088258"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}{version}",
    )
