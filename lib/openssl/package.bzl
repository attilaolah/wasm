"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "openssl"
VERSION = "3.0.5"

URL = "https://www.{name}.org/source/{name}-{version}.tar.gz"

SHA256 = "aa7d8d9bef71ad6525c55ba11e5f4397889ce49c2c9349dcea6d3e4f0b024a7a"

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
