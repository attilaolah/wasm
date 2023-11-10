"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "webp"
VERSION = "1.3.2"
SHA256 = "2a499607df669e40258e53d0ade8035ba4ec0175244869d1025d460562aa09b4"

URL = "https://storage.googleapis.com/downloads.webmproject.org/releases/{name}/lib{name}-{version}.tar.gz"

STATIC_LIBS = [
    static_lib(NAME + suffix)
    for suffix in [
        # keep sorted
        "",
        "decoder",
        "demux",
        "mux",
    ]
] + [static_lib("sharpyuv")]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
    )
