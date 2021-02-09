"""WebAssembly wasm_library() implementation.

Allows implementing JavaScript APIs for C/C++ libraries.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@build_bazel_rules_nodejs//:providers.bzl", "JSModuleInfo")
load("@rules_foreign_cc//tools/build_defs:cc_toolchain_util.bzl", "get_flags_info")

# Linker flags not supported by the wasm-ld linker:
WASM_LD_UNSUPPORTED_FLAGS = [
    "-Wl,-as-needed",
    "-Wl,-no-as-needed",
]

def _find_file(files, name):
    for f in files:
        if f.basename == name:
            return f
    fail("Failed to find {}!".format(name))

def _transition_impl(settings, attr):
    return {
        # Old C++ CPU/CROSSTOOL toolchain API:
        "//command_line_option:cpu": "wasm32",
    }

def _rule_impl(ctx):
    emcc = _find_file(ctx.files._emscripten, "emcc")
    python = _find_file(ctx.files._python, "python.sh")

    # Find the "node_modules" diectory provided by @npm.
    # This is where @npm//acorn (and other npm packages) live.
    acorn = _find_file(ctx.files._acorn, "package.json")
    node_modules = paths.dirname(acorn.dirname)

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
    settings.setdefault("STRICT", "1")
    settings.setdefault("MODULARIZE", "1")
    settings.setdefault("WASM_BIGINT", "1")
    settings.setdefault("INCOMING_MODULE_JS_API", "[onRuntimeInitialized]")
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

    # Build args:
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

    # Append C/C++ compiler flags:
    flags = get_flags_info(ctx)
    args.add_all(flags.cc)
    args.add_all([
        flag
        for flag in flags.cxx_linker_executable
        if flag not in WASM_LD_UNSUPPORTED_FLAGS
    ])

    inputs = (
        ctx.files._emscripten +
        ctx.files._python +
        ctx.files._python_runtime +
        ctx.files._node +
        ctx.files._acorn +
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
            # Emscripten binary:
            "EMCC": emcc.path,
            # Required by the Emscripten config:
            "EMSCRIPTEN": emcc.dirname,
            # Emscripten config file:
            "EM_CONFIG": ctx.file._emscripten_config.path,
            # Required by acorn-optimizer to load @npm//acorn.
            "NODE_PATH": node_modules,
            # Python wrapper script:
            "PYTHON": python.path,
            # Configure ROOT_PATH for //tools/python:
            "ROOT_PATH": ctx.files._python_runtime[0].path,
        },
        mnemonic = "EMCC",
    )

    return [
        DefaultInfo(files = depset([lib_js, lib_wasm])),
        OutputGroupInfo(js = [lib_js], wasm = [lib_wasm]),
    ]

wasm32_transition = transition(
    implementation = _transition_impl,
    inputs = [],
    outputs = ["//command_line_option:cpu"],
)

wasm_library = rule(
    implementation = _rule_impl,
    attrs = {
        "build_settings": attr.string_dict(
            mandatory = False,
            doc = "Additional settings to pass to emcc via -s key=value.",
            default = {},
        ),
        "deps": attr.label_list(
            mandatory = True,
            doc = "Dependencies that provide static libraries to be linked.",
            cfg = wasm32_transition,
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
        "srcs": attr.label_list(
            mandatory = True,
            doc = "Sources to pass to emcc using --pre-js.",
            providers = [JSModuleInfo],
        ),
        "_acorn": attr.label(
            default = "@npm//acorn",
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
        "_emscripten": attr.label(
            default = "@emscripten//:all",
        ),
        "_emscripten_config": attr.label(
            allow_single_file = True,
            default = "@emsdk//emscripten_toolchain:emscripten_config",
        ),
        "_emscripten_emcc": attr.label(
            allow_single_file = [".sh"],
            default = "//tools/emscripten:emcc",
            executable = True,
            cfg = "exec",
        ),
        "_node": attr.label(
            allow_single_file = True,
            default = "@nodejs_linux_amd64//:node",
        ),
        "_python": attr.label(
            default = "//tools/python",
            cfg = "exec",
        ),
        "_python_runtime": attr.label(
            default = "//lib/python:runtime",
            cfg = "exec",
        ),
    },
    fragments = ["cpp"],
)
