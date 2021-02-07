"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "2.0.13"

def download_emscripten():
    http_archive(
        name = "emsdk",
        version = VERSION,
        urls = ["https://github.com/emscripten-core/emsdk/archive/{version}.tar.gz"],
        sha256 = "1bacabdfa07e8565f269e99bcdfa13bf832d6fa64a784a40114deaca45572542",
        strip_prefix = "emsdk-{version}/bazel",
        build_file_content = None,
        patches = ["//tools/emscripten:emsdk.patch"],
    )

    # TODO: Remove when fixed:
    # https://github.com/emscripten-core/emsdk/issues/696
    http_archive(
        name = "emscripten",
        version = VERSION,
        urls = ["https://storage.googleapis.com/webassembly/emscripten-releases-builds/linux/ce0e4a4d1cab395ee5082a60ebb4f3891a94b256/wasm-binaries.tbz2"],
        sha256 = "8986ed886e111c661099c5147126b8a379a4040aab6a1f572fe01f0f9b99a343",
        strip_prefix = "install",
        build_file = "@emsdk//emscripten_toolchain:emscripten.BUILD",
        build_file_content = None,
        patch_cmds = [
            # Remove files containing whitespace,
            # Otherwise they cause issues when symlinking sh_binary() runfiles.
            "rm -r emscripten/third_party/websockify/Windows",
        ],
        type = "tar.bz2",
    )
