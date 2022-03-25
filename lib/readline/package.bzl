"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "readline"
VERSION = "8.0"

URL = "https://ftp.gnu.org/gnu/{name}/{name}-{version}.tar.gz"

SHA256 = "e339f51971478d369f8a053a330a190781acb9864cf4c541060f12078948e461"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
