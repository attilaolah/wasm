"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "x265"
VERSION = "3.5"
SHA256 = "e70a3335cacacbba0b3a20ec6fecd6783932288ebc8163ad74bcc9606477cae8"

URL = "https://bitbucket.org/multicoreware/{name}_git/downloads/{name}_{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}_{version}",
        patches = ["//lib/x265:x265.patch"],
    )
