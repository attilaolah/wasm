load("@bazel_skylib//lib:paths.bzl", "paths")
load("@build_bazel_rules_nodejs//:providers.bzl", "JSModuleInfo")

def _find_file(files, name):
    for f in files:
        if f.basename == name:
            return f
    fail("Failed to find {}!".format(name))

def _transition_impl(settings, attr):
    return {
        # New Platforms toolchain API:
        "//command_line_option:platforms": "//platforms:wasm64",
        # Old C++ CPU/CROSSTOOL toolchain API:
        "//command_line_option:cpu": "wasm64",
    }

def _rule_impl(ctx):
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

    # Replace _wasm suffix with .js and .wasm.
    short_name = ctx.attr.name
    if short_name.endswith("_wasm"):
        short_name = short_name[:-len("_wasm")]

    # Create a copy of build_settings:
    settings = dict(ctx.attr.build_settings.items())

    # Default settings:
    settings.setdefault("MODULARIZE", "1")
    settings.setdefault("EXPORT_NAME", short_name.upper())

    # Override settings:
    if ctx.attr.exported_functions:
        lst = ",".join(exported_functions)
        settings["EXPORTED_FUNCTIONS"] = "[{}]".format(lst)
    if ctx.attr.exported_runtime_methods:
        lst = ",".join(ctx.attr.exported_runtime_methods)
        settings["EXPORTED_RUNTIME_METHODS"] = "[{}]".format(lst)

    # Declare the library wrapper and the binary file:.
    lib_js = ctx.actions.declare_file("{}.js".format(short_name))
    lib_wasm = ctx.actions.declare_file("{}.wasm".format(short_name))

    args = ctx.actions.args()
    args.add("-o", lib_js)
    for flag, val in settings.items():
        if val != "1":
            flag += "={}".format(val)
        args.add("-s", flag)
    for src in ctx.attr.srcs:
        for js in src[JSModuleInfo].direct_sources.to_list():
            args.add("--pre-js", js)
    args.add_all(static_libs)

    inputs = (
        ctx.files._emscripten +
        ctx.files._binaryen +
        ctx.files._llvm +
        ctx.files._node +
        static_libs
    ) + [
        ctx.file._emscripten_config,
    ]
    for src in ctx.attr.srcs:
        for js in src[JSModuleInfo].direct_sources.to_list():
            inputs.append(js)

    ctx.actions.run(
        executable = ctx.executable._emscripten_emcc,
        arguments = [args],
        inputs = inputs,
        outputs = [
            lib_js,
            lib_wasm,
        ],
        env = {
            "EMCC": emcc.path,
            "EM_CONFIG": ctx.file._emscripten_config.path,

            # Values for EM_CONFIG content.
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

    return DefaultInfo(files = depset([lib_js, lib_wasm]))

wasm64_transition = transition(
    implementation = _transition_impl,
    inputs = [],
    outputs = [
        "//command_line_option:platforms",
        "//command_line_option:cpu",
    ],
)

wasm_library = rule(
    implementation = _rule_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            doc = "Sources to pass to emcc using --pre-js.",
            providers = [JSModuleInfo],
            #allow_files = [".js"],
        ),
        "deps": attr.label_list(
            mandatory = True,
            doc = "Dependencies that provide static libraries to be linked.",
            cfg = wasm64_transition,
        ),
        "build_settings": attr.string_dict(
            mandatory = False,
            doc = "Additional settings to pass to emcc via -s key=value.",
            default = {},
        ),
        "exported_functions": attr.string_list(
            mandatory = False,
            doc = "List of C/C++ functions to export.",
            default = [],
        ),
        "exported_runtime_methods": attr.string_list(
            mandatory = False,
            doc = "List of Emscripten runtime methods to export.",
            default = [],
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
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
    },
)
