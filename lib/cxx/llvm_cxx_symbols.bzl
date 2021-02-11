"""Extract a symbol table from LLVM libc++."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//tools:archive_symbols.bzl", "ArchiveSymbolsInfo")

def _llvm_cxx_symbols_impl(ctx):
    cxx = None
    cxxabi = None

    outputs = []
    for f in ctx.files._llvm:
        if cxx and cxxabi:
            break
        if f.dirname != "external/llvm/lib":
            continue
        if f.basename == "libc++.a":
            cxx = f
            continue
        if f.basename == "libc++abi.a":
            cxxabi = f
            continue

    cxxabi_sym = _build_symbol(ctx, cxxabi)
    cxx_sym = _build_symbol(ctx, cxx, [cxxabi_sym])

    return [
        DefaultInfo(files = depset([cxx_sym, cxxabi_sym])),
        ArchiveSymbolsInfo(),
    ]

def _build_symbol(ctx, f, deps = None):
    if deps == None:
        deps = []

    output = ctx.actions.declare_file(
        "symbols/{}".format(
            paths.replace_extension(f.basename, ".json"),
        ),
    )

    args = ctx.actions.args()
    args.add("-nm", ctx.file._nm)
    args.add("-archive", f)
    args.add("-output", output)

    inputs = [ctx.file._nm, f]
    for dep in ctx.attr.deps:
        for ext in dep.files.to_list():
            args.add("-externs", ext)
        inputs.extend(dep.files.to_list())
    for ext in deps:
        args.add("-externs", ext)
    inputs.extend(deps)

    ctx.actions.run(
        executable = ctx.executable._nm_json,
        arguments = [args],
        inputs = inputs,
        outputs = [output],
        mnemonic = "A2JSON",
    )
    return output

llvm_cxx_symbols = rule(
    implementation = _llvm_cxx_symbols_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [ArchiveSymbolsInfo],
            doc = "List of dependencies for resolving external symbols.",
        ),
        "_llvm": attr.label(
            default = "@llvm//:all",
        ),
        "_nm": attr.label(
            allow_single_file = True,
            default = "@llvm//:nm",
        ),
        "_nm_json": attr.label(
            default = "//cmd/nm_json",
            executable = True,
            cfg = "exec",
        ),
    },
)
