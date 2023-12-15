"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.1.51"

URL = "https://github.com/emscripten-core/{name}/archive/refs/tags/{version}.tar.gz"

def download_emscripten():
    http_archive(
        name = "emsdk",
        version = VERSION,
        urls = [URL],
        sha256 = "6edeb200c28505db64a1a9f14373ecc3ba3151cebf3d8314895e603561bc61c2",
        strip_prefix = "{name}-{version}/bazel",
        build_file_content = None,
        patches = ["//tools/emscripten:emsdk.patch"],
    )
