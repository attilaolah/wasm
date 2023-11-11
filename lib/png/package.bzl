"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "major_minor", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "png"
VERSION = "1.6.40"
SHA256 = "535b479b2467ff231a3ec6d92a525906fb8ef27978be4f66dbe05d3f3a01b3a1"

URL = "https://downloads.sourceforge.net/lib{name}/lib{name}-{version}.tar.xz"

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
