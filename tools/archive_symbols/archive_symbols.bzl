"""Contains a rule and helper macro for extracting archive symbols.

The generated symbols are stored in JSON format and can be used for symbol
resolution checking or generating dependency graphs.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

ArchiveSymbolsInfo = provider(
    "Marker for rules that generate archive symbol files.",
    fields = None,
)

def archive_symbols(name, deps, strict):
    """Convenience macro for generating archive symbols for a library.

    Args:
      name: Name of the target, *without* the _symbols suffix.
      deps: Dependencies. Implicit deps (C and GCC libs) will be added.
      strict: Whether the build should fail if any undefined symbols are found.
    """
    labels = []
    for dep in deps:
        if dep.startswith(":"):
            dep = "//{}{}".format(native.package_name(), dep)
        label = Label(dep)
        labels.append("@{}//{}:{}_symbols".format(label.workspace_name, label.package, label.name))

    _archive_symbols(
        name = "{}_symbols".format(name),
        srcs = [":{}".format(name)],
        deps = labels + [
            # Implicit dependencies, keep sorted:
            "//lib/c:c_symbols",
            "//lib/gcc:gcc_symbols",
        ],
        strict = strict,
    )

def _archive_symbols_impl(ctx):
    args = ctx.actions.args()
    args.add("-nm", ctx.file._nm)
    args.add("-extern_only")

    if ctx.attr.strict:
        args.add("-strict")
    else:
        args.add("-strict=false")

    symbols_dir = None

    inputs = []
    outputs = []
    for src in ctx.attr.srcs:
        for linker_input in src[CcInfo].linking_context.linker_inputs.to_list():
            if linker_input.owner != src.label:
                continue
            for lib in linker_input.libraries:
                inputs.append(lib.static_library)
                output = ctx.actions.declare_file(
                    "symbols/{}".format(
                        paths.replace_extension(lib.static_library.basename, ".json"),
                    ),
                )
                outputs.append(output)
                args.add("-archive", lib.static_library)

                if symbols_dir == None:
                    symbols_dir = output.dirname
                    args.add("-output", "{}/{{archive}}.json".format(symbols_dir))

    if not outputs:
        # Header-only libraries have no library outputs.
        return [DefaultInfo(), ArchiveSymbolsInfo()]

    for dep in ctx.attr.deps:
        for ext in dep.files.to_list():
            args.add("-externs", ext)
        inputs.extend(dep.files.to_list())

    ctx.actions.run(
        executable = ctx.executable._archive_symbols,
        arguments = [args],
        inputs = [ctx.file._nm] + inputs,
        outputs = outputs,
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
        "strict": attr.bool(
            default = True,
            doc = "In strict mode, the build will fail if undefined symbols are found in any archive file.",
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

def _static_symbols_impl(ctx):
    return [
        DefaultInfo(files = depset(ctx.files.srcs)),
        ArchiveSymbolsInfo(),
    ]

static_symbols = rule(
    implementation = _static_symbols_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".json"],
            doc = "Pre-generated JSON files.",
        ),
    },
)
