"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "python"
VERSION = "3.9.5"

URL = "https://www.{name}.org/ftp/{name}/{version}/{tname}-{version}.tar.xz"

SHA256 = "0c5a140665436ec3dbfbb79e2dfb6d192655f26ef4a29aeffcb6d1820d716d83"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{tname}-{version}",
    )
