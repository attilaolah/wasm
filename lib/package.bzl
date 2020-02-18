load("//lib/gif:package.bzl", "download_gif")
load("//lib/lz4:package.bzl", "download_lz4")
load("//lib/webp:package.bzl", "download_webp")
load("//lib/z:package.bzl", "download_z")
load("//lib/zstd:package.bzl", "download_zstd")

def download_lib():
    """Download all library sources."""
    download_gif()
    download_lz4()
    download_webp()
    download_z()
    download_zstd()
