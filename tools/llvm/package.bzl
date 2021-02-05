"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "11.0.1"

URL = "https://github.com/{name}/{name}-project/releases/download/{name}org-{version}/clang+{name}-{version}-x86_64-linux-gnu-ubuntu-20.10.tar.xz"

SHA256 = "b60f68581182ace5f7d4a72e5cce61c01adc88050acb72b2070ad298c25071bc"

def download_llvm():
    http_archive(
        name = "llvm",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "clang+{name}-{version}-x86_64-linux-gnu-ubuntu-20.10",
    )
