def _impl(ctx):
    emcc = None
    for f in ctx.files._emscripten:
        if f.basename == "emcc":
            emcc = f
            break
    if emcc == None:
        fail("Failed to find emcc in @emscripten//:all!")

    static_libs = []
    for f in ctx.files.deps:
        # This picks up all static libraries.
        # Maybe it would be better to use providers and explicit static_libraries.
        if f.extension == "a":
            static_libs.append(f)
    if not static_libs:
        fail("No static libraries found!")

    exported_functions = [
        "_{}".format(function)
        for function in ctx.attr.exported_functions
    ]

    # Build the test file.
    test_js = ctx.actions.declare_file("{}.js".format(ctx.attr.name))
    test_wasm = ctx.actions.declare_file("{}.wasm".format(ctx.attr.name))

    args = ctx.actions.args()
    args.add("-o", test_js)
    args.add("-s", "EXPORTED_FUNCTIONS=[{}]".format(",".join(exported_functions)))

    # TODO: Use real dependencies here.
    # TODO: Don't use the deprecated literal em-config, instead write it to a template.
    args.add("--em-config", "BINARYEN_ROOT='/tmp/binaryen-version_97/k8';LLVM_ROOT='/tmp/clang+llvm-11.0.0-rc3-x86_64-linux-gnu-ubuntu-20.04/bin';NODE_JS='/tmp/node-v14.11.0-linux-x64/bin/node';CACHE='/tmp/em_cache'")

    args.add("--extern-pre-js", ctx.file._nodejs_shebang)
    for src in ctx.files.srcs:
        args.add("--post-js", src)
    args.add("--post-js", ctx.file._add_on_init)
    args.add_all(static_libs)

    ctx.actions.run(
        executable = emcc,
        arguments = [args],
        inputs = ctx.files._emscripten + ctx.files.srcs + static_libs + [
            ctx.file._nodejs_shebang,
            ctx.file._add_on_init,
        ],
        outputs = [
            test_js,
            test_wasm,
        ],
    )

    return DefaultInfo(
        executable = test_js,
        runfiles = ctx.runfiles(files = ctx.files._node + [test_wasm]),
    )

wasm_test = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".js"],
            doc = "JavaScript source files containing the tests.",
        ),
        "exported_functions": attr.string_list(
            mandatory = True,
            doc = "List of C/C++ functions to export.",
        ),
        "deps": attr.label_list(
            mandatory = True,
            doc = "Dependencies that provide static libraries to be linked.",
        ),
        "_emscripten": attr.label(
            default = "@emscripten//:all",
            cfg = "host",
        ),
        "_binaryen": attr.label(
            default = "//tools/binaryen",
            cfg = "host",
        ),
        "_llvm": attr.label(
            default = "@llvm//:all",
            cfg = "host",
        ),
        "_node": attr.label(
            default = "//tools:nodejs",
            cfg = "host",
        ),
        "_nodejs_shebang": attr.label(
            allow_single_file = [".sh"],
            default = "//tools/wasm_test:nodejs_shebang.sh",
        ),
        "_add_on_init": attr.label(
            allow_single_file = [".js"],
            default = "//tools/wasm_test:add_on_init.js",
        ),
        #"_emscripten_config": attr.label(
        #    allow_single_file = [".py"],
        #    default = "//config:emscripten_config",
        #    cfg = "host",
        #),
    },
    test = True,
)
