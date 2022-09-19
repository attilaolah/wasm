"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "major_minor", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "python"
VERSION = "3.10.7"

URL = "https://www.{name}.org/ftp/{name}/{version}/{tname}-{version}.tar.xz"

SHA256 = "6eed8415b7516fb2f260906db5d48dd4c06acc0cb24a7d6cc15296a604dcdc48"

STATIC_LIBS = [static_lib(NAME + major_minor(VERSION))]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{tname}-{version}",
    )
