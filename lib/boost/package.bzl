"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.77.0"

URL = "https://boostorg.jfrog.io/ui/api/v1/download?repoKey=main&path=release/{version}/source/boost_{version_}.tar.gz"

SHA256 = "5347464af5b14ac54bb945dc68f1dd7c56f0dad7262816b956138fc53bcc0131"

def download():
    http_archive(
        name = "lib_boost",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        type = "tar.gz",
        strip_prefix = "boost_{version_}",
        patch_cmds = [
            # Remove files with Non-ASCII names to prevent Bazel from freaking out.
            "rm -r libs/wave/test/testwave/testfiles/utf8-test-*",
        ],
    )
