"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")
load(
    "//lib:defs.bzl",
    _link_flags = "link_flags",
    _repo_name = "repo_name",
)

NAME = "lzma"
VERSION = "5.2.5"

URL = "https://tukaani.org/xz/xz-{version}.tar.xz"

SHA256 = "3e1e518ffc912f86608a8cb35e4bd41ad1aec210df2a47aaa1f95e7f5576ef56"

def link_flags():
    return _link_flags(NAME)

def download_lzma():
    http_archive(
        name = _repo_name(NAME),
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "xz-{version}",
    )
