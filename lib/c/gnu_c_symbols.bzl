"""Extract a symbol table from gnu libc."""

load("//tools:archive_symbols.bzl", "ArchiveSymbolsInfo")

def _gnu_c_symbols_impl(ctx):
    return [
        DefaultInfo(files = depset(ctx.files.srcs)),
        ArchiveSymbolsInfo(),
    ]

gnu_c_symbols = rule(
    implementation = _gnu_c_symbols_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".json"],
        ),
    },
)
