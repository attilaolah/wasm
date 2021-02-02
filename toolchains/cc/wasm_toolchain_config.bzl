load(":clang.bzl", "LINUX_X86_64", "LLVM_PATH", "clang_cc_toolchain", "clang_cc_toolchain_config")

def wasm_toolchain(cpu):
    name = "linux_x86_64_{}".format(cpu)
    name_cc_toolchain = "{}_cc_toolchain".format(name)

    compile_flags = [
        # Using the stack protector breaks some builds.
        # See https://github.com/emscripten-core/emscripten/issues/9780.
        "-fno-stack-protector",
        # Set MEMORY64={0,1,2} based on the target CPU architecture.
        "-s MEMORY64={}".format({
            "wasm32": 0,
            "wasm64": 1,
            "wasm64_32": 2,
        }[cpu]),
        # Enable Emscripten "strict" build mode.
        "-s STRICT",
        # Enable JavaScript BigInt support.
        "-s WASM_BIGINT",
    ]

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

    clang_cc_toolchain(name = name_cc_toolchain)

    clang_cc_toolchain_config(
        name = "{}_config".format(name_cc_toolchain),
        cpu = cpu,
        compile_flags = compile_flags,
        link_flags = [
            # These linker flags somehow break libpng when linking binaries.
            # However, they are mostly irrelevant for static archives, which is
            # what we care about when linking with Emscripten anyway.
            #"-Wl,-z,relro,-z,now",
            "-lm",
        ],
        tool_paths = {
            "ar": "/.${EXT_BUILD_DEPS}/bin/emscripten/emar",
            "cpp": "/.${EXT_BUILD_DEPS}/bin/emscripten/em++",
            "gcc": "/.${EXT_BUILD_DEPS}/bin/emscripten/emcc",
            "ld": "/.{}/bin/wasm-ld".format(LLVM_PATH),
        },
    )
