"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "0.27.3"

URL = "https://exiv2.org/builds/exiv2-{version}-Source.tar.gz"

SHA256 = "a79f5613812aa21755d578a297874fb59a85101e793edc64ec2c6bd994e3e778"

def download_exiv2():
    http_archive(
        name = "lib_exiv2",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "exiv2-{version}-Source",
    )
