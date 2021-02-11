"""Contains a rule and helper macro for extracting archive symbols.

The generated symbols are stored in JSON format and can be used for symbol
resolution checking or generating dependency graphs.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

ArchiveSymbolsInfo = provider(
    "Marker for rules that generate archive symbol files.",
    fields = None,
)

def archive_symbols(name, deps):
    """Convenience macro for generating archive symbols for a library."""
    deps = [Label(dep) for dep in deps]
    deps = [
        Label("@{}//{}:{}_symbols".format(dep.workspace_name, dep.package, dep.name))
        for dep in deps
    ] + [
        # Implicit dependencies, keep sorted:
        "//lib/c:c_symbols",
        "//lib/cxx:cxx_symbols",
    ]

    _archive_symbols(
        name = "{}_symbols".format(name),
        srcs = [":{}".format(name)],
        deps = deps,
    )

def _archive_symbols_impl(ctx):
    outputs = []
    for src in ctx.attr.srcs:
        for linker_input in src[CcInfo].linking_context.linker_inputs.to_list():
            if linker_input.owner != src.label:
                continue
            for lib in linker_input.libraries:
                output = ctx.actions.declare_file(
                    "symbols/{}".format(
                        paths.replace_extension(lib.static_library.basename, ".json"),
                    ),
                )
                outputs.append(output)

                args = ctx.actions.args()
                args.add("-nm", ctx.file._nm)
                args.add("-archive", lib.static_library)
                args.add("-extern_only")
                args.add("-output", output)

                inputs = [ctx.file._nm, lib.static_library]
                for dep in ctx.attr.deps:
                    for ext in dep.files.to_list():
                        args.add("-externs", ext)
                    inputs.extend(dep.files.to_list())

                ctx.actions.run(
                    executable = ctx.executable._archive_symbols,
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
        "_archive_symbols": attr.label(
            default = "//tools/archive_symbols",
            executable = True,
            cfg = "exec",
        ),
        "_nm": attr.label(
            allow_single_file = True,
            default = "@llvm//:nm",
        ),
    },
)
