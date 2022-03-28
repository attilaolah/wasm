"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "major")

NAME = "fftw"
VERSION = "3.3.9"

URL = "http://www.{name}.org/{name}-{version}.tar.gz"

SHA256 = "bf2c7ce40b04ae811af714deb512510cc2c17b9ab9d6ddcf49fe4487eea7af3d"

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
