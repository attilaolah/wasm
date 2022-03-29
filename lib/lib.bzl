load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("//tools:version_info.bzl", "version_info")

def package_lib(version_url = None, version_regex = None):
    """Common package contents for most packages under //lib."""
    bzl_library(
        name = "package",
        srcs = ["package.bzl"],
        deps = [
            "//lib:defs",
            "//lib:http_archive",
        ],
    )
    if version_url != None and version_regex != None:
        version_info(
            version_url = version_url,
            version_regex = version_regex,
        )
