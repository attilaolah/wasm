"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "4.2.15"

URL = "https://support.hdfgroup.org/ftp/HDF/releases/HDF{version}/src/hdf-{version}.tar.gz"

SHA256 = "dbeeef525af7c2d01539906c28953f0fdab7dba603d1bc1ec4a5af60d002c459"

def download():
    http_archive(
        name = "hdf",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "hdf-{version}",
    )
