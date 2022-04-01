"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "dep_spec", "include_dir", "library_path", "major", "major_minor", "static_lib")

NAME = "openjpeg"
VERSION = "2.4.0"

URL = "https://github.com/uclouvain/{name}/archive/v{version}.tar.gz"

SHA256 = "8702ba68b442657f11aaeb2b338443ca8d5fb95b0d845757968a7be31ef7f16d"

LNAME = NAME[:-2] + major(VERSION)

STATIC_LIBS = [static_lib(LNAME)]

SPEC = dep_spec(
    name = NAME,
    include_dir = include_dir(NAME, "{}-{}".format(NAME, major_minor(VERSION))),
    library = library_path(NAME, STATIC_LIBS[0]),
)

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = ["//lib/openjpeg:openjpeg.patch"],
    )
