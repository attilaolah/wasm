"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "nasm"
VERSION = "2.16.01"
SHA256 = "c77745f4802375efeee2ec5c0ad6b7f037ea9c87c92b149a9637ff099f162558"

URL = "https://www.{name}.us/pub/{name}/releasebuilds/{version}/{name}-{version}.tar.xz"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = ["//lib/nasm:nasm.patch"],
    )
