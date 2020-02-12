load("//:http_archive.bzl", "http_archive")

NAME = "zlib"
VERSION = "1.2.11"

URL = "http://downloads.sourceforge.net/libpng/{name}-{version}.tar.gz"

SHA256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1"

def download_src():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
