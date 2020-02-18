load("//lib/gif:package.bzl", "download_gif")
load("//lib/lz4:package.bzl", "download_lz4")
load("//lib/lzma:package.bzl", "download_lzma")
load("//lib/png:package.bzl", "download_png")
load("//lib/tiff:package.bzl", "download_tiff")
load("//lib/webp:package.bzl", "download_webp")
load("//lib/z:package.bzl", "download_z")
load("//lib/zstd:package.bzl", "download_zstd")

def download_lib():
    """Download all library sources."""
    download_gif()
    download_lz4()
    download_lzma()
    download_png()
    download_tiff()
    download_webp()
    download_z()
    download_zstd()
