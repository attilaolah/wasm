"""Utility that helps checking for upstream versions of libraries."""

load("@bazel_skylib//:bzl_library.bzl", "StarlarkLibraryInfo")

VersionInfo = provider(
    "Version information, contained in JSON files.",
    fields = {
        "version_infos": "A depset of JSON files.",
    },
)

def _version_info_impl(ctx):
    package_bzl = ctx.attr.package_bzl[StarlarkLibraryInfo].srcs[0]

    args = ctx.actions.args()
    args.add("-version_url", ctx.attr.version_url)
    args.add("-version_regex", ctx.attr.version_regex)
    args.add("-package_bzl", package_bzl)

    version_json = ctx.actions.declare_file("{}.json".format(ctx.attr.name))
    args.add("-output", version_json)

    ctx.actions.run(
        executable = ctx.executable._parser,
        arguments = [args],
        inputs = [package_bzl],
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

    updater_cmd = _UPDATER_CMD.format(
        package_bzl = package_bzl.path,
        version_specs = " ".join([v.path for v in version_specs]),
        jq = ctx.executable._jq.path,
    )

    executable = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = executable,
        content = updater_cmd,
        is_executable = True,
    )

    return [DefaultInfo(
        executable = executable,
        runfiles = ctx.runfiles([ctx.executable._jq] + version_specs),
    )]

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
        "_parser": attr.label(
            default = "//tools/version_info/parser",
            executable = True,
            cfg = "exec",
        ),
    },
)

version_update = rule(
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
        "_jq": attr.label(
            default = "//tools:jq",
            executable = True,
            cfg = "exec",
        ),
    },
)

_UPDATER_CMD = r"""
jq="{jq}"
package_bzl="{package_bzl}"
version_specs=({version_specs})

echo "Updating ${{package_bzl}}:"

cd "${{BUILD_WORKSPACE_DIRECTORY}}"
for spec in ${{version_specs[@]}}; do
  up_to_date=$("${{jq}}" -r '.up_to_date // false' < "${{spec}}")
  "${{jq}}" . < "${{spec}}"
  if [ "${{up_to_date}}" == "true" ]; then
    continue
  fi

  version="$("${{jq}}" -r .version < "${{spec}}")"
  upstream_version="$("${{jq}}" -r .upstream_version < "${{spec}}")"
  url="$("${{jq}}" -r .urls[0] < "${{spec}}")"
  url="$(sed "s/${{version}}/${{upstream_version}}/g" <<< "${{url}}")"
  tmp="$(mktemp)"

  curl "${{url}}" --output "${{tmp}}" --silent

  checksum="$(sha256sum "${{tmp}}" | awk '{{ print $1 }}')"

  sed -i "${{package_bzl}}" \
    -e "s/VERSION = \"${{version}}\"/VERSION = \"${{upstream_version}}\"/"
  sed -i "${{package_bzl}}" \
    -e "s/SHA256 = \".*\"/SHA256 = \"${{checksum}}\"/"
done

echo "Done!"
"""
