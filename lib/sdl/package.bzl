"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "major")
load("//lib:http_archive.bzl", "http_archive")

NAME = "sdl"
VERSION = "2.0.20"

URL = "https://www.lib{name}.org/release/{uname}{versionm}-{version}.tar.gz"

SHA256 = "c56aba1d7b5b0e7e999e4a7698c70b63a3394ff9704b5f6e1c57e0c16f04dd06"

def lname(suffix = ""):
    return NAME.upper() + major(VERSION) + suffix

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{uname}{versionm}-{version}",
    )
