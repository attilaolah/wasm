"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")
load(
    "//lib:defs.bzl",
    _include_dir = "include_dir",
    _library_path = "library_path",
    _link_flags = "link_flags",
    _repo_name = "repo_name",
)

NAME = "zstd"
VERSION = "1.5.0"

URL = "https://github.com/facebook/zstd/releases/download/v{version}/zstd-{version}.tar.gz"

SHA256 = "5194fbfa781fcf45b98c5e849651aa7b3b0a008c6b72d4a0db760f3002291e94"

def include_dir():
    return _include_dir(NAME)

def library_path():
    return _library_path(NAME)

def link_flags():
    return _link_flags(NAME)

def download():
    http_archive(
        name = _repo_name(NAME),
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "zstd-{version}",
    )
