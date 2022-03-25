"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

VERSION = "1.0.4"

URL = "https://gitlab.dkrz.de/k202009/libaec/uploads/ea0b7d197a950b0c110da8dfdecbb71f/libaec-{version}.tar.gz"

SHA256 = "f2b1b232083bd8beaf8a54a024225de3dd72a673a9bcdf8c3ba96c39483f4309"

def download():
    http_archive(
        name = "aec",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libaec-{version}",
        patches = ["//lib/aec:aec.patch"],
    )
