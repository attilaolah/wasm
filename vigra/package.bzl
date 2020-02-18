load("//:http_archive.bzl", "http_archive")

NAME = "vigra"
VERSION = "1.11.1"

URL = "https://github.com/ukoethe/{name}/releases/download/Version-{version-}/{name}-{version}-src.tar.gz"

SHA256 = "a5564e1083f6af6a885431c1ee718bad77d11f117198b277557f8558fa461aaf"

def download_src():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = [
            "//vigra:CMakeLists.txt.patch",
            "//vigra:output_cplusplus_version.cxx.patch",
        ],
    )
