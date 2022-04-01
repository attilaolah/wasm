load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("//tools:version_info.bzl", "version_info")

def package_lib(runtime_for = (), version_url = None, version_regex = None):
    """Common package contents for most packages under //lib."""
    bzl_library(
        name = "package",
        srcs = ["package.bzl"],
        deps = [
            "//lib:defs",
            "//lib:http_archive",
        ],
    )

    for label in runtime_for:
        name = "runtime"
        if len(runtime_for) > 1:
            name = "_".join((label, name))
        native.filegroup(
            name = name,
            srcs = [":{}".format(label)],
            output_group = "gen_dir",
        )

    if version_url != None and version_regex != None:
        version_info(
            version_url = version_url,
            version_regex = version_regex,
        )
