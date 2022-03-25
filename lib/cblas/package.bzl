"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "cblas"
VERSION = "3.8.0"

URL = "http://www.netlib.org/blas/blast-forum/{name}.tgz"

SHA256 = "0f6354fd67fabd909baf57ced2ef84e962db58fae126e4f41b21dd4fec60a2a3"

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{uname}",
        patch_cmds = [
            # Bazel will exclude empty directories from the symlink tree.
            # So add a dummy file to prevent the "lib" dir from being excluded.
            "touch lib/.keep",
            # The makefile hard-codes "make".
            # We want to use $(MAKE) instead so the toolchain's make tool gets used.
            r"sed -i Makefile -e 's/\bmake\b/$(MAKE)/g'",
        ],
    )
