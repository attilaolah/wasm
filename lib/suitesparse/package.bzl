"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "5.9.0"
METIS_VERSION = "5.1.0"

METIS_PATH = "metis-{}".format(METIS_VERSION)

GK_PATH = "{}/GKlib".format(METIS_PATH)

URL = "https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v{version}.tar.gz"

SHA256 = "7bdd4811f1cf0767c5fdb5e435817fdadee50b0acdb598f4882ae7b8291a7f24"

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
