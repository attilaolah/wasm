load("//lib/gif:package.bzl", "download_gif")
load("//lib/webp:package.bzl", "download_webp")

def download_lib():
    """Download all library sources."""
    download_gif()
    download_webp()
