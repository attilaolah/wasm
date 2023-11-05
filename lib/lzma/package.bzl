"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "lzma"
VERSION = "5.4.5"
SHA256 = "da9dec6c12cf2ecf269c31ab65b5de18e8e52b96f35d5bcd08c12b43e6878803"

URL = "https://tukaani.org/xz/xz-{version}.tar.xz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "xz-{version}",
    )
