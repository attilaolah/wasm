"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "major_minor", "static_lib")

NAME = "python"
VERSION = "3.10.4"

URL = "https://www.{name}.org/ftp/{name}/{version}/{tname}-{version}.tar.xz"

SHA256 = "80bf925f571da436b35210886cf79f6eb5fa5d6c571316b73568343451f77a19"

STATIC_LIBS = [static_lib(NAME + major_minor(VERSION))]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{tname}-{version}",
    )
