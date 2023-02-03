"""Rule to produce a package.json file for publishing."""

def _package_json_impl(ctx):
    output = ctx.actions.declare_file(ctx.attr.name.removesuffix("_json") + ".json")
    args = ctx.actions.args()
    args.add("-input", ctx.files.src[0])
    args.add("-output", output)
    if ctx.attr.module:
        args.add("-module", ctx.attr.module)

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
        "module": attr.string(
            doc = "Overrife for the 'module' field.",
        ),
        "_package_json": attr.label(
            default = "//tools/package_json",
            executable = True,
            cfg = "exec",
        ),
    },
)
