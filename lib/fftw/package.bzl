"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "major", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "fftw"
VERSION = "3.3.10"
SHA256 = "56c932549852cddcfafdab3820b0200c7742675be92179e59e6215b340e26467"

URL = "http://www.{name}.org/{name}-{version}.tar.gz"

LNAMES = {
    suffix: NAME + major(VERSION) + suffix
    for suffix in ["", "f", "l", "q"]
}

STATIC_LIBS = {
    suffix: [static_lib(lname)]
    for suffix, lname in LNAMES.items()
}

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
