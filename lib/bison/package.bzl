"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "bison"
VERSION = "3.7.6"

URL = "https://ftp.gnu.org/gnu/{name}/{name}-{version}.tar.xz"

SHA256 = "67d68ce1e22192050525643fc0a7a22297576682bef6a5c51446903f5aeef3cf"

STATIC_LIBS = [static_lib("y")]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
