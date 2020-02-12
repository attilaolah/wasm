load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")

BUILD_FILE_CONTENT = """
filegroup(
    name = "all",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""

def http_archive(name, version, urls, sha256, strip_prefix = None):
    """Wrapper around http_archive() that specifies a common BUILD file."""
    if strip_prefix != None:
        strip_prefix = strip_prefix.format(name = name, version = version)

    _http_archive(
        name = name.replace("-", "_"),
        urls = [url.format(name = name, version = version) for url in urls],
        sha256 = sha256,
        strip_prefix = strip_prefix,
        build_file_content = BUILD_FILE_CONTENT,
    )
