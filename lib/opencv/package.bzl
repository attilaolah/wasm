"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "static_lib")

NAME = "opencv"
VERSION = "4.5.5"

URL = "https://github.com/{name}/{name}/archive/{version}.zip"

SHA256 = "fb16b734db3a28e5119d513bd7c61ef417edf3756165dc6259519bb9d23d04e2"

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
