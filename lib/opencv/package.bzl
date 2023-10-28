"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "opencv"
VERSION = "4.6.0"
SHA256 = "158db5813a891c7eda8644259fc1dbd76b21bd1ffb9854a8b4b8115a4ceec359"

URL = "https://github.com/{name}/{name}/archive/{version}.zip"

STATIC_LIBS = [
    static_lib("_".join((NAME, lib)))
    for lib in [
        # keep sorted
        "calib3d",
        "core",
        "dnn",
        "features2d",
        "flann",
        "gapi",
        "highgui",
        "imgcodecs",
        "imgproc",
        "ml",
        "objdetect",
        "photo",
        "stitching",
        "video",
        "videoio",
    ]
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
