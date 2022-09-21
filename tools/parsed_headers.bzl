"""Rule for parsing header files."""

_DIR = "hdrs"

def _parsed_headers_impl(ctx):
    outputs = []

    common_args = ctx.actions.args()
    for dep in ctx.attr.deps:
        for path in dep[CcInfo].compilation_context.system_includes.to_list():
            common_args.add("-I", path)

    for hdr in ctx.attr.hdrs:
        # Create a temporary file that includes the header.
        # This is to avoid having to know where the file is located.
        name, _, ext = hdr.rpartition(".")
        wrapper = ctx.actions.declare_file("{}/{}.0.{}".format(_DIR, name, ext))
        ctx.actions.write(wrapper, '#include "{}"'.format(hdr))

        # Translate input filename to output filename, according to the rule:
        # - example.h -> example.i
        # - example.hpp -> example.ii
        # - anything_else -> anything_else.i
        cpp_ext = {
            "h": "i",
            "hpp": "ii",
        }.get(ext, "{}.i".format(ext))
        name_i = ctx.actions.declare_file("{}/{}.0.{}".format(_DIR, name, cpp_ext))
        outputs.append(name_i)

        args = ctx.actions.args()
        args.add("-o", name_i)
        args.add(wrapper)

        ctx.actions.run(
            executable = ctx.executable._clang_cpp,
            arguments = [common_args, args],
            inputs = [wrapper] + ctx.files.deps,
            outputs = [name_i],
            progress_message = "Preprocessing {}".format(hdr),
            mnemonic = "CPP",
        )

        # Pretty-print the output.
        # This makes the result easier to parse.
        name_i_1 = ctx.actions.declare_file("{}/{}.1.{}".format(_DIR, name, cpp_ext))
        outputs.append(name_i_1)

        args = ctx.actions.args()
        args.add_all([ctx.executable._clang_format, name_i, name_i_1])

        # NOTE: clang-format cannot redirect its output, so we use run_shell().
        ctx.actions.run_shell(
            command = "$1 $2 --style '{MaxEmptyLinesToKeep: 0, ColumnLimit: 1000}' > $3",
            tools = [ctx.executable._clang_format],
            arguments = [args],
            inputs = [name_i],
            outputs = [name_i_1],
            progress_message = "Formatting {}".format(name_i.basename),
            mnemonic = "FMT",
        )

    return DefaultInfo(files = depset(outputs))


parsed_headers = rule(
    implementation = _parsed_headers_impl,
    attrs = {
        'hdrs': attr.string_list(
            doc = "List of header files to process.",
            mandatory = True,
        ),
        'deps': attr.label_list(
            doc = "Dependencies that provide the header files.",
            providers = [CcInfo],
            mandatory = True,
        ),
        "_clang_cpp": attr.label(
            default = "@llvm//:clang-cpp",
            executable = True,
            cfg = "exec",
        ),
        "_clang_format": attr.label(
            default = "@llvm//:clang-format",
            executable = True,
            cfg = "exec",
        ),
    }
)

