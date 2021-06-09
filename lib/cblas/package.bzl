"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "3.8.0"

URL = "http://www.netlib.org/blas/blast-forum/cblas.tgz"

SHA256 = "0f6354fd67fabd909baf57ced2ef84e962db58fae126e4f41b21dd4fec60a2a3"

def download_cblas():
    http_archive(
        name = "lib_cblas",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "CBLAS",
        # Bazel will exclude empty directories from the symlink tree.
        # So add a dummy file to prevent the "lib" dir from being excluded.
        patch_cmds = ["touch lib/.keep"],
    )
