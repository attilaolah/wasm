"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "lcms"
VERSION = "2.12"

URL = "https://downloads.sourceforge.net/project/{name}/{name}/{version}/{name}{versionm}-{version}.tar.gz"

SHA256 = "18663985e864100455ac3e507625c438c3710354d85e5cbb7cd4043e11fe10f5"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{versionm}-{version}",
    )
