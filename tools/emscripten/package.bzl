"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.1.47"

URL = "https://github.com/emscripten-core/{name}/archive/refs/tags/{version}.tar.gz"

def download_emscripten():
    http_archive(
        name = "emsdk",
        version = VERSION,
        urls = [URL],
        sha256 = "a882560a83cbacec67867e7ce6b00420d557e71c501b523d2ed956ded021f9b4",
        strip_prefix = "{name}-{version}/bazel",
        build_file_content = None,
        patches = ["//tools/emscripten:emsdk.patch"],
    )
