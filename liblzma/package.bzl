load("//:http_archive.bzl", "http_archive")

NAME = "liblzma"
VERSION = "5.2.4"

URL = "https://tukaani.org/xz/xz-{version}.tar.gz"

SHA256 = "b512f3b726d3b37b6dc4c8570e137b9311e7552e8ccbab4d39d47ce5f4177145"

def download_src():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "xz-{version}",
    )
