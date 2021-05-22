"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.5.0"

URL = "https://github.com/facebook/zstd/releases/download/v{version}/zstd-{version}.tar.gz"

SHA256 = "5194fbfa781fcf45b98c5e849651aa7b3b0a008c6b72d4a0db760f3002291e94"

def download_zstd():
    http_archive(
        name = "lib_zstd",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "zstd-{version}",
    )
