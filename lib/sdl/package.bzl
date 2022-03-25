"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "2.0.20"

URL = "https://www.libsdl.org/release/SDL2-{version}.tar.gz"

SHA256 = "c56aba1d7b5b0e7e999e4a7698c70b63a3394ff9704b5f6e1c57e0c16f04dd06"

def download():
    http_archive(
        name = "sdl",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "SDL2-{version}",
    )
