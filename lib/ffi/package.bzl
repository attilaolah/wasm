"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "3.3"

URL = "https://github.com/libffi/libffi/releases/download/v{version}/libffi-{version}.tar.gz"

SHA256 = "72fba7922703ddfa7a028d513ac15a85c8d54c8d67f55fa5a4802885dc652056"

def download():
    http_archive(
        name = "ffi",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libffi-{version}",
    )
