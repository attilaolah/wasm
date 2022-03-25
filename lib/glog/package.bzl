"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "glog"
VERSION = "0.4.0"

URL = "https://github.com/google/{name}/archive/v{version}.tar.gz"

SHA256 = "f28359aeba12f30d73d9e4711ef356dc842886968112162bc73002645139c39c"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
