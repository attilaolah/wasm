"""Rule to produce NPM packge contents and the package.json file."""

def _package_contents_impl(ctx):
    outputs = []
    args = ctx.actions.args()
    for src in ctx.files.srcs:
        args.add("-input", src.path)
    for out, glob in ctx.attr.outputs.items():
        if ctx.attr.outdir_name:
            out = "{}/{}".format(ctx.attr.outdir_name, out)
        outf = ctx.actions.declare_file(out)
        args.add("-output", "{}={}".format(outf.path, glob))
        outputs.append(outf)

    ctx.actions.run(
        executable = ctx.executable._package_contents,
        arguments = [args],
        inputs = ctx.files.srcs,
        outputs = outputs,
        mnemonic = "PKG",
    )

    return DefaultInfo(files = depset(outputs))

package_contents = rule(
    implementation = _package_contents_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = ["LICENSE", ".js", ".css"],
            doc = "Source files.",
        ),
        "outputs": attr.string_dict(
            doc = "Map of output files to source globs.",
        ),
        "outdir_name": attr.string(
            doc = "Output directory.",
        ),
        "_package_contents": attr.label(
            default = "//tools/package_contents",
            executable = True,
            cfg = "exec",
        ),
    },
)

def _package_json_impl(ctx):
    output = ctx.actions.declare_file(ctx.attr.name.removesuffix("_json") + ".json")
    args = ctx.actions.args()
    args.add("-input", ctx.files.src[0])
    args.add("-output", output)

    ctx.actions.run(
        executable = ctx.executable._package_json,
        arguments = [args],
        inputs = ctx.files.src,
        outputs = [output],
        mnemonic = "PKG",
    )

    return DefaultInfo(files = depset([output]))

package_json = rule(
    implementation = _package_json_impl,
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = [".json"],
            doc = "Input package.json file.",
        ),
        "_package_json": attr.label(
            default = "//tools/package_json",
            executable = True,
            cfg = "exec",
        ),
    },
)
