"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "ffi"
VERSION = "3.3"
SHA256 = "72fba7922703ddfa7a028d513ac15a85c8d54c8d67f55fa5a4802885dc652056"

URL = "https://github.com/lib{name}/lib{name}/releases/download/v{version}/lib{name}-{version}.tar.gz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "lib{name}-{version}",
    )
