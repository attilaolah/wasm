"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load(
    "//lib:defs.bzl",
    _include_dir = "include_dir",
    _library_path = "library_path",
    _link_flags = "link_flags",
)

NAME = "webp"
VERSION = "1.1.0"

URL = "https://storage.googleapis.com/downloads.webmproject.org/releases/{name}/lib{name}-{version}.tar.gz"

SHA256 = "98a052268cc4d5ece27f76572a7f50293f439c17a98e67c4ea0c7ed6f50ef043"

def include_dir():
    return _include_dir(NAME)

def library_path():
    return _library_path(NAME)

def link_flags():
    return _link_flags(NAME)

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
    )
