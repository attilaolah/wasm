"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "major", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "lcms"
VERSION = "2.12"
SHA256 = "18663985e864100455ac3e507625c438c3710354d85e5cbb7cd4043e11fe10f5"

URL = "https://downloads.sourceforge.net/project/{name}/{name}/{version}/{name}{versionm}-{version}.tar.gz"

STATIC_LIBS = [static_lib(NAME + major(VERSION))]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}{versionm}-{version}",
    )
