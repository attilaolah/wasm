"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "4.5.5"

URL = "https://github.com/opencv/opencv/archive/{version}.zip"

SHA256 = "fb16b734db3a28e5119d513bd7c61ef417edf3756165dc6259519bb9d23d04e2"

def download():
    http_archive(
        name = "opencv",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "opencv-{version}",
    )
