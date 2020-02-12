load("//:http_archive.bzl", "http_archive")

NAME = "lz4"
VERSION = "1.9.2"

URL = "https://github.com/lz4/lz4/archive/v{version}.tar.gz"

SHA256 = "658ba6191fa44c92280d4aa2c271b0f4fbc0e34d249578dd05e50e76d0e5efcc"

def download_src():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
