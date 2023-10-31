"""Rule for constructing a notebook page."""

load("@bazel_skylib//lib:shell.bzl", "shell")

def _page_impl(ctx):
    output_html = ctx.actions.declare_file("{}.html".format(ctx.attr.name))
    ctx.actions.run_shell(
        command = "\n".join([
            'echo "<!doctype html>" > {output_html}',
            'echo "<script type="module" src="{loader_js}" async></script><body><!--" >> {output_html}',
        ] + [
            "cat {src} >> {{output_html}}".format(src = shell.quote(src.path))
            for src in ctx.files.srcs
        ] + [
            'echo "-->" >> {output_html}',
        ]).format(
            loader_js = ctx.attr.loader_js,
            output_html = shell.quote(output_html.path),
        ),
        inputs = ctx.files.srcs,
        outputs = [output_html],
    )
    return DefaultInfo(files = depset([output_html]))

page = rule(
    implementation = _page_impl,
    attrs = {
        "loader_js": attr.string(
            doc = "URL to load the notebook.js file from.",
            default = "/dist/pkg/webnb.js",
        ),
        "srcs": attr.label_list(
            doc = "Markdown files to include in the output.",
            allow_files = [".md"],
            mandatory = True,
        ),
    },
)
