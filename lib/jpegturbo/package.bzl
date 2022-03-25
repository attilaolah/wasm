"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load(
    "//lib:defs.bzl",
    _include_dir = "include_dir",
    _library_dir = "library_dir",
    _link_flags = "link_flags",
)

NAME = "jpegturbo"
VERSION = "2.1.0"

URL = "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/{version}.tar.gz"

SHA256 = "d6b7790927d658108dfd3bee2f0c66a2924c51ee7f9dc930f62c452f4a638c52"

def lname():
    return "turbojpeg"

def link_flags():
    return _link_flags(lname(), _library_dir(NAME))

def download_jpegturbo():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libjpeg-turbo-{version}",
    )
