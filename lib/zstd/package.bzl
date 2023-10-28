"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "zstd"
VERSION = "1.5.0"
SHA256 = "5194fbfa781fcf45b98c5e849651aa7b3b0a008c6b72d4a0db760f3002291e94"

URL = "https://github.com/facebook/{name}/releases/download/v{version}/{name}-{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
