load("@bazel_skylib//lib:paths.bzl", "paths")

ArchiveSymbolInfo = provider()

def archive_symbols(name, deps):
    """Convenience macro for generating archive symbols for a library."""
    deps = [Label(dep) for dep in deps]
    deps = [
        Label("@{}//{}:{}_symbols".format(dep.workspace_name, dep.package, dep.name))
        for dep in deps
    ]

    _archive_symbols(
        name = "{}_symbols".format(name),
        srcs = [":{}".format(name)],
        deps = deps,
    )

def _archive_symbols_impl(ctx):
    nm = [f for f in ctx.files._llvm if f.basename == "llvm-nm"][0]

    outputs = []
    for src in ctx.attr.srcs:
        for linker_input in src[CcInfo].linking_context.linker_inputs.to_list():
            for lib in linker_input.libraries:
                output = ctx.actions.declare_file(
                    paths.replace_extension(lib.static_library.basename, ".json"),
                )
                outputs.append(output)

                args = ctx.actions.args()
                args.add("-nm", nm)
                args.add("-archive", lib.static_library)
                args.add("-output", output)

                ctx.actions.run(
                    executable = ctx.executable._nm_json,
                    arguments = [args],
                    inputs = [nm, lib.static_library],
                    outputs = [output],
                    mnemonic = "A2JSON",
                )

    return [
        DefaultInfo(files = depset(outputs)),
        ArchiveSymbolInfo(),
    ]

_archive_symbols = rule(
    implementation = _archive_symbols_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [ArchiveSymbolInfo],
            doc = "List of dependencies for resolving external symbols.",
        ),
        "srcs": attr.label_list(
            mandatory = True,
            providers = [CcInfo],
            doc = "List of archive files to process.",
        ),
        "_llvm": attr.label(
            default = "@llvm//:all",
        ),
        "_nm_json": attr.label(
            default = "//cmd/nm_json",
            executable = True,
            cfg = "exec",
        ),
    },
)
