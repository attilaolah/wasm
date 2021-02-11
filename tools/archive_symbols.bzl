load("@bazel_skylib//lib:paths.bzl", "paths")

ArchiveSymbolsInfo = provider()

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
            if linker_input.owner != src.label:
                continue
            for lib in linker_input.libraries:
                output = ctx.actions.declare_file(
                    paths.replace_extension(lib.static_library.basename, ".json"),
                )
                outputs.append(output)

                args = ctx.actions.args()
                args.add("-nm", nm)
                args.add("-archive", lib.static_library)
                args.add("-type", "FUNC")
                args.add("-extern_only")
                args.add("-output", output)

                inputs = [nm, lib.static_library]
                for dep in ctx.attr.deps:
                    for f in dep.files.to_list():
                        args.add("-externs", f)
                    inputs.extend(dep.files.to_list())

                ctx.actions.run(
                    executable = ctx.executable._nm_json,
                    arguments = [args],
                    inputs = inputs,
                    outputs = [output],
                    mnemonic = "A2JSON",
                )

    return [
        DefaultInfo(files = depset(outputs)),
        ArchiveSymbolsInfo(),
    ]

_archive_symbols = rule(
    implementation = _archive_symbols_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [ArchiveSymbolsInfo],
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
