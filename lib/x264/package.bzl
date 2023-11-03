"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "x264"
VERSION = "0.164.3161"
COMMIT = "a354f11f8f019a2a34ae7ef554ff07b31f0818f3"
SHA256 = "3f87b564f71e7fccf2b58c1bafcdb74b88ce2d57fff5cf870a5703fb33691d38"

URL = "https://code.videolan.org/videolan/{name}/-/archive/" + COMMIT + "/{name}-" + COMMIT + ".tar.bz2"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-" + COMMIT,
    )
