load("//:http_archive.bzl", "http_archive")

NAME = "libjpeg-turbo"
VERSION = "2.0.4"

URL = "https://download.sourceforge.net/libjpeg-turbo/{name}-{version}.tar.gz"

SHA256 = "33dd8547efd5543639e890efbf2ef52d5a21df81faf41bb940657af916a23406"

def download_src():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
