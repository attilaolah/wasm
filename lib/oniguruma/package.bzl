"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "oniguruma"
VERSION = "6.9.6"
SHA256 = "bd0faeb887f748193282848d01ec2dad8943b5dfcb8dc03ed52dcc963549e819"

URL = "https://github.com/kkos/{name}/releases/download/v{version}/onig-{version}.tar.gz"

STATIC_LIBS = [static_lib(NAME[:4])]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "onig-{version}",
    )
