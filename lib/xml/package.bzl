"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.9.10"

URL = "http://xmlsoft.org/sources/libxml2-{version}.tar.gz"

SHA256 = "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f"

def download_xml():
    http_archive(
        name = "lib_xml",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libxml2-{version}",
    )
