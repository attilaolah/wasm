load("//:http_archive.bzl", "http_archive")

VERSION = "4.1.0"

URL = "https://download.osgeo.org/libtiff/tiff-{version}.tar.gz"

SHA256 = "5d29f32517dadb6dbcd1255ea5bbc93a2b54b94fbf83653b4d65c7d6775b8634"

def download_tiff():
    http_archive(
        name = "lib_tiff",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "tiff-{version}",
        patches = ["//lib/tiff:CMakeLists.txt.patch"],
    )
