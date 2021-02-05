"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.11.1"

URL = "https://github.com/ukoethe/vigra/releases/download/Version-{version-}/vigra-{version}-src.tar.gz"

SHA256 = "a5564e1083f6af6a885431c1ee718bad77d11f117198b277557f8558fa461aaf"

def download_vigra():
    http_archive(
        name = "lib_vigra",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "vigra-{version}",
        patches = [
            "//lib/vigra:CMakeLists.txt.patch",
            "//lib/vigra:output_cplusplus_version.cxx.patch",
        ],
    )
