"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "ffmpeg"
VERSION = "6.0"
SHA256 = "57be87c22d9b49c112b6d24bc67d42508660e6b718b3db89c44e47e289137082"

URL = "https://{name}.org/releases/{name}-{version}.tar.xz"

LIBS = [
    # keep sorted
    "avcodec",
    "avformat",
    "avutil",
    "swscale",
]

STATIC_LIBS = [static_lib(lib) for lib in LIBS]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = ["//lib/ffmpeg:ffmpeg.patch"],
    )
