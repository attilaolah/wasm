"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "python"
VERSION = "3.10.4"

URL = "https://www.{name}.org/ftp/{name}/{version}/{tname}-{version}.tar.xz"

SHA256 = "80bf925f571da436b35210886cf79f6eb5fa5d6c571316b73568343451f77a19"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{tname}-{version}",
    )
