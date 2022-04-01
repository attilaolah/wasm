"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "major", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "xml"
VERSION = "2.9.10"

URL = "http://{name}soft.org/sources/lib{name}{versionm}-{version}.tar.gz"

SHA256 = "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f"

STATIC_LIBS = [static_lib(NAME + major(VERSION))]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}{versionm}-{version}",
    )
