load(":clang.bzl", "LINUX_X86_64", "LLVM_TOOLS", "clang_cc_toolchain", "clang_cc_toolchain_config")

def wasm_toolchain(cpu):
    name = "linux_x86_64_{}".format(cpu)
    name_cc_toolchain = "{}_cc_toolchain".format(name)

    native.toolchain(
        name = name,
        exec_compatible_with = LINUX_X86_64,
        target_compatible_with = [
            "@platforms//os:none",
            "@platforms//cpu:{}".format(cpu),
        ],
        toolchain = name_cc_toolchain,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )

    # Based on the output of:
    # CC=clang bazel query --output=build @local_config_cc//:cc-compiler-k8

    clang_cc_toolchain(
        name = name_cc_toolchain,
        all_files = "//toolchains:emscripten",
    )

    # Emscripten tools:
    tool_paths = {
        "gcc": "emcc.sh",
        "cpp": "em++.sh",
        "ar": "emar.sh",
    }

    # LLVM tools:
    for tool in LLVM_TOOLS:
        tool_paths[tool] = "external/llvm/llvm-{}".format(tool)

    clang_cc_toolchain_config(
        name = "{}_config".format(name_cc_toolchain),
        cpu = cpu,
        # Using the stack protector breaks some builds.
        # See https://github.com/emscripten-core/emscripten/issues/9780.
        stack_protector = False,
        link_flags = [
            # Disabling lazy binding ("-Wl,-z,now) breaks libpng.
            "-Wl,-z,relro",  #,-z,now",
            "-lm",
        ],
        tool_paths = tool_paths,
    )
