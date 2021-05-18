"""Custom http_archive() macro.

Adds a few convenience methods, most notably templeted URLs and strip_prefix
params, so that the version would need to be passed only once.

The goal is that the version would be stored in only one place, making it
easier to update external dependencies.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")

ALL_PUBLIC = """
filegroup(
    name = "all",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""

def http_archive(
        name,
        version,
        urls,
        strip_prefix = None,
        build_file_content = ALL_PUBLIC,
        **kwargs):
    """Wrapper around http_archive().

    It specifies a common BUILD file by default, which publically exports all
    contents.

    Additionally, it allows template substitution in the URLs and in
    strip_prefix.

    Args:
      name: Converted to snake_case and passed on to http_archive().
      version: Used only for template substitution in the urls and strip_prefix
        params.
      urls: Passed on to http_archive() after template substitution.
      strip_prefix: Passed on to http_archive() after template substitution.
      build_file_content: Passed on to http_archive().
      **kwargs: Passed on to http_archive().

    """
    args = {
        "name": name,
        "version": version,
        "version-": version.replace(".", "-"),
        "version_": version.replace(".", "_"),
        "versionm": version.split(".")[0],
        "versionmm": ".".join(version.split(".")[:2]),
    }

    if strip_prefix != None:
        strip_prefix = strip_prefix.format(**args)

    if build_file_content:
        kwargs["build_file_content"] = build_file_content

    _http_archive(
        name = name.lower().replace("-", "_"),
        urls = [url.format(**args) for url in urls],
        strip_prefix = strip_prefix,
        **kwargs
    )
