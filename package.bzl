load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("//libjpeg_turbo:package.bzl", download_libjpeg_turbo = "download_src")
load("//liblzma:package.bzl", download_liblzma = "download_src")
load("//libpng:package.bzl", download_libpng = "download_src")
load("//zlib:package.bzl", download_zlib = "download_src")
load("//zstd:package.bzl", download_zstd = "download_src")

def register_dependencies():
    """Set up dependencies of THIS workspace."""
    git_repository(
        name = "rules_foreign_cc",
        remote = "https://github.com/bazelbuild/rules_foreign_cc",
        commit = "ed3db61a55c13da311d875460938c42ee8bbc2a5",
        shallow_since = "1574792034 +0100",
    )

    git_repository(
        name = "bazel_skylib",
        remote = "https://github.com/bazelbuild/bazel-skylib",
        commit = "e59b620b392a8ebbcf25879fc3fde52b4dc77535",  # 1.0.2
        shallow_since = "1570639401 -0400",
    )

def register_repositories():
    """Fetch and set up dependencies."""
    download_libjpeg_turbo()
    download_liblzma()
    download_libpng()
    download_zlib()
    download_zstd()
