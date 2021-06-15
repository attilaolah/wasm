"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.0.24"

URL = "https://github.com/emscripten-core/emsdk/archive/{version}.tar.gz"

def download_emscripten():
    http_archive(
        name = "emsdk",
        version = VERSION,
        urls = [URL],
        sha256 = "e9c40a44d4c9e1e3c1fc0520787269ae017dcbbe5be43f9c81c0fabc3204f1a3",
        strip_prefix = "emsdk-{version}/bazel",
        build_file_content = None,
    )
