load("//lib/gif:package.bzl", "download_gif")
load("//lib/webp:package.bzl", "download_webp")
load("//lib/zstd:package.bzl", "download_zstd")

def download_lib():
    """Download all library sources."""
    download_gif()
    download_webp()
    download_zstd()
