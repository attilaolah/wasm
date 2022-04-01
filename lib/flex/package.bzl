"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "flex"
VERSION = "2.6.4"

URL = "https://github.com/westes/{name}/releases/download/v{version}/{name}-{version}.tar.gz"

SHA256 = "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995"

STATIC_LIBS = [static_lib("fl")]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
