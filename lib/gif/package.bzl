"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "gif"
VERSION = "5.2.1"
SHA256 = "31da5562f44c5f15d63340a09a4fd62b48c45620cd302f77a6d9acf0077879bd"

URL = "https://downloads.sourceforge.net/project/{name}lib/{name}lib-{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}lib-{version}",
        patches = ["//lib/gif:gif.patch"],
    )
