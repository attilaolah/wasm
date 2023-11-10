"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", lib_http_archive = "http_archive")

NAME = "ffmpeg"
VERSION = "6.0"
SHA256 = "57be87c22d9b49c112b6d24bc67d42508660e6b718b3db89c44e47e289137082"

URL = "https://{name}.org/releases/{name}-{version}.tar.xz"

LIBS = [
    # keep sorted
    "avcodec",
    "avformat",
    "avutil",
    "swscale",
]

STATIC_LIBS = [static_lib(lib) for lib in LIBS]

BUILD_FILE_CONTENT = """
package(
  default_visibility = ["//visibility:public"],
)

filegroup(
    name = "all",
    srcs = glob(["**"]),
)

exports_files(
    srcs = ["configure"],
)
"""

BUILD_FILE_CONTENT_WASM_BINDINGS = r"""
package(
  default_visibility = ["//visibility:public"],
)

filegroup(
    name = "bind",
    srcs = ["src/bind/ffmpeg/bind.js"],
)

filegroup(
    name = "export",
    srcs = ["src/bind/ffmpeg/export.js"],
)

filegroup(
    name = "export_runtime",
    srcs = ["src/bind/ffmpeg/export-runtime.js"],
)
"""

def download():
    lib_http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = ["//lib/ffmpeg:ffmpeg.patch"],
        build_file_content = BUILD_FILE_CONTENT,
    )
    http_archive(
        name = "ffmpeg_wasm",
        version = "0.12.7",
        urls = ["https://github.com/ffmpegwasm/ffmpeg.wasm/archive/refs/tags/v{version}.tar.gz"],
        sha256 = "b214aaf0fc577237847ee78904e64c3a6b07c5f55b0983cb74b22390c8b7e5b5",
        strip_prefix = "ffmpeg.wasm-{version}",
        build_file_content = BUILD_FILE_CONTENT_WASM_BINDINGS,
    )
