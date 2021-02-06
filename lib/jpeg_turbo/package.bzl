"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.0.90"

URL = "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/{version}.tar.gz"

SHA256 = "6a965adb02ad898b2ae48214244618fe342baea79db97157fdc70d8844ac6f09"

def download_jpeg_turbo():
    http_archive(
        name = "lib_jpeg_turbo",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libjpeg-turbo-{version}",
    )
