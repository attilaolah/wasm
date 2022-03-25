"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "mpfr"
VERSION = "4.1.0"

URLS = [
    "https://www.{name}.org/{name}-current/{name}-{version}.tar.xz",
    "https://ftp.gnu.org/gnu/{name}/{name}-{version}.tar.xz",
]

SHA256 = "0c98a3f1732ff6ca4ea690552079da9c597872d30e96ec28414ee23c95558a7f"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = URLS,
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
