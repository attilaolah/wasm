load("@bazel_skylib//lib:paths.bzl", "paths")

def _find_file(files, name):
    for f in files:
        if f.basename == name:
            return f
    fail("Failed to find {}!".format(name))

def _impl(ctx):
    if ctx.var.get("TARGET_CPU") not in ("wasm32", "wasm64"):
        fail(("Target CPU not supported: '{}'. " +
              "Must be 'wasm32' or 'wasm64'.").format(ctx.var.get("TARGET_CPU")))
    emcc = _find_file(ctx.files._emscripten, "emcc")
    binaryen = _find_file(ctx.files._binaryen, "binaryen")
    clang = _find_file(ctx.files._llvm, "clang")
    node = _find_file(ctx.files._node, "node")

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
    args.add("--extern-pre-js", ctx.file._shebang)
    for src in [ctx.file._wait_for_init] + ctx.files.srcs:
        args.add("--post-js", src)
    args.add_all(static_libs)

    ctx.actions.run(
        executable = ctx.executable._emscripten_emcc,
        arguments = [args],
        inputs = (
            ctx.files._emscripten +
            ctx.files._binaryen +
            ctx.files._llvm +
            ctx.files._node +
            ctx.files.srcs +
            static_libs
        ) + [
            ctx.file._shebang,
            ctx.file._wait_for_init,
            ctx.file._emscripten_config,
        ],
        outputs = [
            test_js,
            test_wasm,
        ],
        env = {
            "EMCC": emcc.path,
            "EM_CONFIG": ctx.file._emscripten_config.path,

            # Valies for EM_CONFIG content.
            # See //tools/emscripten:config.py.
            "EM_CACHE": "/tmp/em_cache",
            "EM_BINARYEN_ROOT": paths.join(binaryen.dirname, "binaryen"),
            "EM_LLVM_ROOT": clang.dirname,
            "EM_NODE_JS": node.path,

            # Add /usr/bin to PATH so that Emscripten could find Python.
            # TODO: Include our own Python (via @rules_python) and remove this.
            "PATH": "/usr/bin",
        },
        mnemonic = "EMCC",
    )

    return DefaultInfo(
        executable = test_js,
        runfiles = ctx.runfiles(files = ctx.files._node + ctx.files._mocha + [
            test_wasm,
        ]),
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
        "_mocha": attr.label(
            default = "@npm//mocha",
            cfg = "host",
        ),
        "_emscripten_emcc": attr.label(
            allow_single_file = [".sh"],
            default = "//tools/emscripten:emcc",
            executable = True,
            cfg = "host",
        ),
        "_emscripten_config": attr.label(
            allow_single_file = [".py"],
            default = "//tools/emscripten:config",
        ),
        "_shebang": attr.label(
            allow_single_file = [".sh"],
            default = "//tools/wasm_test:shebang.sh",
        ),
        "_wait_for_init": attr.label(
            allow_single_file = [".js"],
            default = "//tools/wasm_test:wait_for_init.js",
        ),
    },
    test = True,
)
