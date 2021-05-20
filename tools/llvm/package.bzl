"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")
load("//toolchains/make:configure.bzl", "patch_files")

VERSION = "12.0.0"
VERSION_MMP = VERSION.split("-")[0]
VERSION_ND = VERSION.replace("-", "")

URL = "https://github.com/llvm/llvm-project/releases/download/llvmorg-{version}/clang+llvm-{version}-x86_64-linux-gnu-ubuntu-20.04.tar.xz"
URL_FLANG = "https://github.com/llvm/llvm-project/releases/download/llvmorg-{version}/flang-{version}.src.tar.xz"

SHA256 = "a9ff205eb0b73ca7c86afc6432eed1c2d49133bd0d49e47b15be59bbf0dd292e"
SHA256_FLANG = "dc9420c9f55c6dde633f0f46fe3f682995069cc5247dfdef225cbdfdca79123a"

BUILD = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all",
    srcs = glob(["**"]),
)

filegroup(
    name = "nm",
    srcs = ["bin/llvm-nm"],
)
"""

def download_llvm():
    http_archive(
        name = "llvm",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "clang+llvm-{version}-x86_64-linux-gnu-ubuntu-20.04",
        build_file_content = BUILD,
        patch_cmds = patch_files({
            # Avoid dependency on system libtinfo.so.
            # It breaks the Flang build. Instead, we'll supply a static libtinfo.so.
            "lib/cmake/llvm/LLVMExports.cmake": r"s:;/usr/lib/x86_64-linux-gnu/libtinfo.so;:;:g",
        }),
    )

def download_flang():
    http_archive(
        name = "flang",
        version = VERSION,
        urls = [URL_FLANG],
        sha256 = SHA256_FLANG,
        strip_prefix = "flang-{version}.src"
    )
