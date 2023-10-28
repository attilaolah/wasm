"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "iconv"
VERSION = "1.16"
SHA256 = "e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04"

URL = "https://ftp.gnu.org/pub/gnu/lib{name}/lib{name}-{version}.tar.gz"

STATIC_LIBS = [
    static_lib(NAME),
    static_lib("charset"),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
    )
