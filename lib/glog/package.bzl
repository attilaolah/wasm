"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "0.4.0"

URL = "https://github.com/google/glog/archive/v{version}.tar.gz"

SHA256 = "f28359aeba12f30d73d9e4711ef356dc842886968112162bc73002645139c39c"

def download_glog():
    http_archive(
        name = "lib_glog",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "glog-{version}",
    )
