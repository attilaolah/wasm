"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "major_minor", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "png"
VERSION = "1.6.37"

URL = "https://downloads.sourceforge.net/lib{name}/lib{name}-{version}.tar.gz"

SHA256 = "daeb2620d829575513e35fecc83f0d3791a620b9b93d800b763542ece9390fb4"

STATIC_LIBS = [
    static_lib(NAME),
    static_lib(NAME + major_minor(VERSION, join = "")),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
    )
