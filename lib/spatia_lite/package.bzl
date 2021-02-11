"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "5.0.0"

URL = "http://www.gaia-gis.it/gaia-sins/libspatialite-{version}.tar.gz"

SHA256 = "7b7fd70243f5a0b175696d87c46dde0ace030eacc27f39241c24bac5dfac6dac"

def download_spatia_lite():
    http_archive(
        name = "lib_spatia_lite",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libspatialite-{version}",
    )
