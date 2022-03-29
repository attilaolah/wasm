"""Utility that helps checking for upstream versions of libraries."""

load("@bazel_skylib//:bzl_library.bzl", "StarlarkLibraryInfo")

VersionInfo = provider(
    "Version information, contained in JSON files.",
    fields = {
        "version_infos": "A depset of JSON files.",
    },
)

def version_info(version_url, version_regex, rule_name = "version", package_bzl = ":package"):
    """Convenience macro for creating the version info & updater rules."""
    _version_info(
        name = rule_name,
        package_bzl = package_bzl,
        version_url = version_url,
        version_regex = version_regex,
    )
    _version_update(
        name = rule_name + "_update",
        package_bzl = package_bzl,
        version_specs = [":" + rule_name],
    )

def _version_info_impl(ctx):
    package_bzl = ctx.attr.package_bzl[StarlarkLibraryInfo].srcs[0]
    package_deps = ctx.attr.package_bzl[StarlarkLibraryInfo].transitive_srcs.to_list()

    args = ctx.actions.args()
    args.add("-version_url", ctx.attr.version_url)
    args.add("-version_regex", ctx.attr.version_regex)
    args.add("-package_bzl", package_bzl)

    version_json = ctx.actions.declare_file("{}.json".format(ctx.attr.name))
    args.add("-output", version_json)

    ctx.actions.run(
        executable = ctx.executable._parser,
        arguments = [args],
        inputs = [package_bzl] + package_deps,
        outputs = [version_json],
        mnemonic = "VersionInfo",
    )

    return [
        DefaultInfo(files = depset([version_json])),
        VersionInfo(version_infos = depset([version_json])),
    ]

def _version_update_impl(ctx):
    package_bzl = ctx.attr.package_bzl[StarlarkLibraryInfo].srcs[0]

    version_specs = []
    for version_spec in ctx.attr.version_specs:
        version_specs += version_spec[VersionInfo].version_infos.to_list()

    executable = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = executable,
        is_executable = True,
        substitutions = {
            "${PACKAGE_BZL}": package_bzl.path,
            "${VERSION_SPECS}": " ".join([v.path for v in version_specs]),
            "${JQ}": ctx.executable._jq.path,
        },
    )

    return [DefaultInfo(
        executable = executable,
        runfiles = ctx.runfiles([ctx.executable._jq] + version_specs),
    )]

_version_info = rule(
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
        "_parser": attr.label(
            default = "//tools/version_info/parser",
            executable = True,
            cfg = "exec",
        ),
    },
)

_version_update = rule(
    implementation = _version_update_impl,
    executable = True,
    attrs = {
        "package_bzl": attr.label(
            doc = "Starlark package.bzl file containing version info.",
            providers = [StarlarkLibraryInfo],
            mandatory = True,
        ),
        "version_specs": attr.label_list(
            doc = "Auto-generated VersionInfo JSON file (version.json).",
            providers = [VersionInfo],
        ),
        "_template": attr.label(
            allow_single_file = [".sh"],
            default = "//tools:version_update.sh",
        ),
        "_jq": attr.label(
            default = "//tools:jq",
            executable = True,
            cfg = "exec",
        ),
    },
)
