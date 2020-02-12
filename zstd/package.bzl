load("//:http_archive.bzl", "http_archive")

NAME = "zstd"
VERSION = "1.4.4"

URL = "https://github.com/facebook/{name}/releases/download/v{version}/{name}-{version}.tar.gz".format(name = NAME, version = VERSION)

SHA256 = "59ef70ebb757ffe74a7b3fe9c305e2ba3350021a918d168a046c6300aeea9315"

def download_src():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
