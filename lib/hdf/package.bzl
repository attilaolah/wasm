"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "hdf"
VERSION = "4.2.15"

URL = "https://support.{name}group.org/ftp/{uname}/releases/{uname}{version}/src/{name}-{version}.tar.gz"

SHA256 = "dbeeef525af7c2d01539906c28953f0fdab7dba603d1bc1ec4a5af60d002c459"

STATIC_LIBS = {lib: static_lib(lib) for lib in [
    # keep sorted
    "df",
    "hdf",
    "mfhdf",
    "xdr",
]}

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
