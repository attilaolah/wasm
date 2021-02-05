"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.3.8"

URL = "http://www.fftw.org/fftw-{version}.tar.gz"

SHA256 = "6113262f6e92c5bd474f2875fa1b01054c4ad5040f6b0da7c03c98821d9ae303"

def download_fftw():
    http_archive(
        name = "lib_fftw",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "fftw-{version}",
    )
