"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "major_minor", "static_lib")

NAME = "imath"
VERSION = "3.1.5"

URL = "https://github.com/AcademySoftwareFoundation/{name}/archive/refs/tags/v{version}.tar.gz"

SHA256 = "1e9c7c94797cf7b7e61908aed1f80a331088cc7d8873318f70376e4aed5f25fb"

STATIC_LIBS = [static_lib("-".join((
    NAME.title(),
    major_minor(VERSION, join = "_"),
)))]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{tname}-{version}",
    )
