"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "1.16"

URL = "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-{version}.tar.gz"

SHA256 = "e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04"

def download():
    http_archive(
        name = "iconv",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libiconv-{version}",
    )
