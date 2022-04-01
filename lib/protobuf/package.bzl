"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "protobuf"
VERSION = "3.19.4"

URL = "https://github.com/protocolbuffers/{name}/releases/download/v{version}/{name}-cpp-{version}.tar.gz"

SHA256 = "89ac31a93832e204db6d73b1e80f39f142d5747b290f17340adce5be5b122f94"

STATIC_LIBS = [
    static_lib(NAME),
    static_lib(NAME + "-lite"),
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
