"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "vigra"
VERSION = "1.11.1"

URL = "https://github.com/ukoethe/{name}/releases/download/Version-{version-}/{name}-{version}-src.tar.gz"

SHA256 = "a5564e1083f6af6a885431c1ee718bad77d11f117198b277557f8558fa461aaf"

STATIC_LIBS = [static_lib(NAME + "impex")]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = [
            "//lib/vigra:CMakeLists.txt.patch",
            "//lib/vigra:output_cplusplus_version.cxx.patch",
        ],
    )
