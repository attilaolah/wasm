"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "bison"
VERSION = "3.8.2"
SHA256 = "9bba0214ccf7f1079c5d59210045227bcf619519840ebfa80cd3849cff5a5bf2"

URL = "https://ftp.gnu.org/gnu/{name}/{name}-{version}.tar.xz"

STATIC_LIBS = [static_lib("y")]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
