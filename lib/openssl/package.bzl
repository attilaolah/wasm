"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "static_lib")

NAME = "openssl"
VERSION = "3.0.2"

URL = "https://www.{name}.org/source/{name}-{version}.tar.gz"

SHA256 = "98e91ccead4d4756ae3c9cde5e09191a8e586d9f4d50838e7ec09d6411dfdb63"

LIBS = ["crypto", "ssl"]

STATIC_LIBS = [static_lib(lib) for lib in LIBS]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
