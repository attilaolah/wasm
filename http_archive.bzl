load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")

ALL_PUBLIC = """
filegroup(
    name = "all",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""

def http_archive(name, version, urls, sha256, strip_prefix = None, patches = None, patch_cmds = None):
    """Wrapper around http_archive() that specifies a common BUILD file."""
    args = {
        "name": name,
        "version": version,
        "version-": version.replace(".", "-"),
        "version_": version.replace(".", "_"),
    }

    if strip_prefix != None:
        strip_prefix = strip_prefix.format(**args)

    _http_archive(
        name = name.replace("-", "_"),
        urls = [url.format(**args) for url in urls],
        sha256 = sha256,
        strip_prefix = strip_prefix,
        build_file_content = ALL_PUBLIC,
        patches = patches,
        patch_cmds = patch_cmds,
    )
