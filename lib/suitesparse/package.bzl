"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "5.8.1"

METIS_VERSION = "5.1.0"

URL = "https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v{version}.tar.gz"

SHA256 = "06726e471fbaa55f792578f9b4ab282ea9d008cf39ddcc3b42b73400acddef40"

def download_suitesparse():
    http_archive(
        name = "lib_suitesparse",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "SuiteSparse-{version}",
        patches = [
            "//lib/suitesparse:CMakeLists.txt.patch",
        ],
    )
