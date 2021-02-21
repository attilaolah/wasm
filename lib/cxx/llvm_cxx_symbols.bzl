"""Extract a symbol table from LLVM libc++."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//tools/archive_symbols:archive_symbols.bzl", "ArchiveSymbolsInfo")

CXX_LIBS = [
    # keep sorted
    "libc++.a",
    "libc++abi.a",
]

def _llvm_cxx_symbols_impl(ctx):
    args = ctx.actions.args()
    args.add("-nm", ctx.file._nm)
    args.add("-extern_only")

    symbols_dir = None

    inputs = []
    outputs = []
    for lib in ctx.files._llvm:
        if lib.basename not in CXX_LIBS:
            continue

        inputs.append(lib)
        output = ctx.actions.declare_file(
            "symbols/{}".format(
                paths.replace_extension(lib.basename, ".json"),
            ),
        )
        outputs.append(output)
        args.add("-archive", lib)

        if symbols_dir == None:
            symbols_dir = output.dirname
            args.add("-output", "{}/{{archive}}.json".format(symbols_dir))

    deps = []
    for dep in ctx.attr.deps:
        for ext in dep.files.to_list():
            args.add("-externs", ext)
        inputs.extend(dep.files.to_list())
    for ext in deps:
        args.add("-externs", ext)
    inputs.extend(deps)

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

llvm_cxx_symbols = rule(
    implementation = _llvm_cxx_symbols_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [ArchiveSymbolsInfo],
            doc = "List of dependencies for resolving external symbols.",
        ),
        "_archive_symbols": attr.label(
            default = "//tools/archive_symbols",
            executable = True,
            cfg = "exec",
        ),
        "_llvm": attr.label(
            default = "@llvm//:all",
        ),
        "_nm": attr.label(
            allow_single_file = True,
            default = "@llvm//:nm",
        ),
    },
)
