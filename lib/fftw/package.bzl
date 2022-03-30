"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "major")

NAME = "fftw"
VERSION = "3.3.10"

URL = "http://www.{name}.org/{name}-{version}.tar.gz"

SHA256 = "56c932549852cddcfafdab3820b0200c7742675be92179e59e6215b340e26467"

def lname(suffix = ""):
    return NAME + major(VERSION) + suffix

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
