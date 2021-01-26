load("//:http_archive.bzl", "http_archive")

VERSION = "1.4.8"

URL = "https://github.com/facebook/zstd/releases/download/v{version}/zstd-{version}.tar.gz"

SHA256 = "32478297ca1500211008d596276f5367c54198495cf677e9439f4791a4c69f24"

def download_zstd():
    http_archive(
        name = "lib_zstd",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "zstd-{version}",
    )
