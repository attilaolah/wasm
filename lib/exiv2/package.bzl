"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "0.27.5"

URL = "https://github.com/Exiv2/exiv2/releases/download/v{version}/exiv2-{version}-Source.tar.gz"

SHA256 = "35a58618ab236a901ca4928b0ad8b31007ebdc0386d904409d825024e45ea6e2"

def download():
    http_archive(
        name = "lib_exiv2",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "exiv2-{version}-Source",
    )
