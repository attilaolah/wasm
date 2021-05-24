"""Utility that helps checking for upstream versions of libraries."""

load("@bazel_skylib//:bzl_library.bzl", "StarlarkLibraryInfo")

def _version_info_impl(ctx):
    package_bzl = ctx.attr.package_bzl[StarlarkLibraryInfo].srcs[0]

    args = ctx.actions.args()
    args.add("-version_url", ctx.attr.version_url)
    args.add("-version_regex", ctx.attr.version_regex)
    args.add("-package_bzl", package_bzl)

    version_json = ctx.actions.declare_file("{}.json".format(ctx.attr.name))
    args.add("-output", version_json)

    ctx.actions.run(
        executable = ctx.executable._version_info,
        arguments = [args],
        inputs = [package_bzl],
        outputs = [version_json],
        mnemonic = "VersionInfo",
    )

    return [DefaultInfo(files = depset([version_json]))]

version_info = rule(
    implementation = _version_info_impl,
    attrs = {
        "package_bzl": attr.label(
            doc = "Starlark package.bzl file containing version info.",
            providers = [StarlarkLibraryInfo],
            mandatory = True,
        ),
        "version_regex": attr.string(
            doc = "Regular expression that should match the upstream version(s).",
            mandatory = True,
        ),
        "version_url": attr.string(
            doc = "HTTP(S) link containing upstream version info.",
            mandatory = True,
        ),
        "_version_info": attr.label(
            default = "//tools/version_info",
            executable = True,
            cfg = "exec",
        ),
    },
)
