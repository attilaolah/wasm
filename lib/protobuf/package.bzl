"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.19.4"

URL = "https://github.com/protocolbuffers/protobuf/releases/download/v{version}/protobuf-cpp-{version}.tar.gz"

SHA256 = "89ac31a93832e204db6d73b1e80f39f142d5747b290f17340adce5be5b122f94"

def download_protobuf():
    http_archive(
        name = "lib_protobuf",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "protobuf-{version}",
    )
