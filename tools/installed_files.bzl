load("@bazel_skylib//lib:paths.bzl", "paths")

def _installed_files_impl(ctx):
    return [DefaultInfo(files = depset([
        dep
        for dep in ctx.files.deps
        if (dep.is_directory and
            paths.basename(dep.dirname).startswith("copy_"))
    ]))]

installed_files = rule(
    implementation = _installed_files_impl,
    attrs = {
        "deps": attr.label_list(
            doc = "List of targets built with cmake_external(), configure_make() or make().",
            mandatory = True,
        ),
    },
)
