"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.1.8"

URL = "https://github.com/emscripten-core/{name}/archive/refs/tags/{version}.tar.gz"

def download_emscripten():
    http_archive(
        name = "emsdk",
        version = VERSION,
        urls = [URL],
        sha256 = "98e2a5b5aefd6beb8265991cdde2992f4eac1aacbad52da425f877b823de9560",
        strip_prefix = "{name}-{version}/bazel",
        build_file_content = None,
        patches = ["//tools/emscripten:emsdk.patch"],
    )
