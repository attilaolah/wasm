"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "static_lib")

NAME = "aec"
VERSION = "1.0.6"

URL = "https://gitlab.dkrz.de/k202009/lib{name}/-/archive/v{version}/lib{name}-v{version}.tar.bz2"

SHA256 = "31fb65b31e835e1a0f3b682d64920957b6e4407ee5bbf42ca49549438795a288"

STATIC_LIBS = [static_lib(lib) for lib in (NAME, "sz")]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-v{version}",
    )
