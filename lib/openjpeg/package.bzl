"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load(
    "//lib:defs.bzl",
    "major",
    "major_minor",
    _include_dir = "include_dir",
    _library_path = "library_path",
)

NAME = "openjpeg"
VERSION = "2.4.0"
URL = "https://github.com/uclouvain/openjpeg/archive/v{version}.tar.gz"
SHA256 = "8702ba68b442657f11aaeb2b338443ca8d5fb95b0d845757968a7be31ef7f16d"

def lname():
    return NAME[:-2] + major(VERSION)

def include_dir():
    return _include_dir(NAME, [
        "{}-{}".format(NAME, major_minor(VERSION)),
    ])

def library_path():
    return _library_path(NAME, lname())

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "openjpeg-{version}",
        patches = ["//lib/openjpeg:openjpeg.patch"],
    )
