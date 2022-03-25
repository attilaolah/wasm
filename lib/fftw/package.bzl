"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.3.9"

URL = "http://www.fftw.org/fftw-{version}.tar.gz"

SHA256 = "bf2c7ce40b04ae811af714deb512510cc2c17b9ab9d6ddcf49fe4487eea7af3d"

def download():
    http_archive(
        name = "lib_fftw",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "fftw-{version}",
    )
