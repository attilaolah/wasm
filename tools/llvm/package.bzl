"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")
load("//toolchains/make:configure.bzl", "patch_files")

VERSION = "12.0.0-rc2"
VERSION_MMP = VERSION.split("-")[0]
VERSION_ND = VERSION.replace("-", "")

URL = "https://github.com/llvm/llvm-project/releases/download/llvmorg-{version}/clang+llvm-{version}-x86_64-linux-gnu-ubuntu-20.10.tar.xz"
URL_FLANG = "https://github.com/llvm/llvm-project/releases/download/llvmorg-{}/flang-{}.src.tar.xz".format(VERSION, VERSION_ND)

SHA256 = "70d15e6284e43472c04d28c6fe9db39f6f46aceafd0e9f6fe2f73f4e2d235fdc"
SHA256_FLANG = "383c8041665f26bab7eb2dca215a020f7cb4f074f2f043c03e9f7b7576f51d23"

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
        strip_prefix = "clang+llvm-{version}-x86_64-linux-gnu-ubuntu-20.10",
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
        strip_prefix = "flang-{}.src".format(VERSION_ND),
    )
