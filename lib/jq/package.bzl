"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.6"

URL = "https://github.com/stedolan/jq/releases/download/jq-{version}/jq-{version}.tar.gz"

SHA256 = "5de8c8e29aaa3fb9cc6b47bb27299f271354ebb72514e3accadc7d38b5bbaa72"

def download():
    http_archive(
        name = "lib_jq",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "jq-{version}",
    )
