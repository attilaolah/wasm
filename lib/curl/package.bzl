"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "curl"
VERSION = "7.85.0"
SHA256 = "88b54a6d4b9a48cb4d873c7056dcba997ddd5b7be5a2d537a4acb55c20b04be6"

URL = "https://{name}.se/download/{name}-{version}.tar.xz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
