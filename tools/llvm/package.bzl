"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")
load("//:versions.bzl", "OS_VERSION")
load("//toolchains:utils.bzl", "patch_files")

VERSION = "17.0.2"
VERSION_MMP = VERSION.split("-")[0]
VERSION_ND = VERSION.replace("-", "")

URL = "https://github.com/llvm/llvm-project/releases/download/llvmorg-{version}/clang+llvm-{version}-x86_64-linux-gnu-" + OS_VERSION + ".tar.xz"
URL_FLANG = "https://github.com/llvm/llvm-project/releases/download/llvmorg-{version}/flang-{version}.src.tar.xz"

SHA256 = "df297df804766f8fb18f10a188af78e55d82bb8881751408c2fa694ca19163a8"
SHA256_FLANG = "6eae496b648c1e6891da72db827c6d2801959620564f96787c7b440567a66029"

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
        strip_prefix = "clang+llvm-{version}-x86_64-linux-gnu-" + OS_VERSION,
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
        strip_prefix = "flang-{version}.src",
    )
