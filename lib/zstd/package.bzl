load("//:http_archive.bzl", "http_archive")

VERSION = "1.4.4"

URL = "https://github.com/facebook/zstd/releases/download/v{version}/zstd-{version}.tar.gz"

SHA256 = "59ef70ebb757ffe74a7b3fe9c305e2ba3350021a918d168a046c6300aeea9315"

def download_zstd():
    http_archive(
        name = "lib_zstd",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "zstd-{version}",
    )
