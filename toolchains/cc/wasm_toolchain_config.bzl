load("@local_config_cc//:cc_toolchain_config.bzl", "cc_toolchain_config")

WASM_ABIS = [32, 64]

WASM_CPUS = ["wasm{}".format(abi) for abi in WASM_ABIS]

def wasm_toolchains(exec_os, exec_cpu):
    for cpu in WASM_CPUS:
        wasm_toolchain(exec_os, exec_cpu, cpu)

def wasm_toolchain(exec_os, exec_cpu, cpu):
    name = "_".join((exec_os, exec_cpu, cpu))
    name_cc = "{}_cc".format(name)
    config = "{}_toolchain_config".format(cpu)

    native.toolchain(
        name = name,
        exec_compatible_with = [
            "@platforms//os:{}".format(exec_os),
            "@platforms//cpu:{}".format(exec_cpu),
        ],
        target_compatible_with = [
            "@platforms//os:none",
            "@platforms//cpu:{}".format(cpu),
        ],
        toolchain = name_cc,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )

    # Based on the output of:
    # CC=clang bazel query --output=build @local_config_cc//:cc-compiler-k8

    native.cc_toolchain(
        name = name_cc,
        all_files = ":empty",
        ar_files = "@emscripten//:all",
        as_files = ":empty",
        compiler_files = "@emscripten//:all",
        dwp_files = ":empty",
        linker_files = ":empty",
        objcopy_files = ":empty",
        strip_files = ":empty",
        supports_param_files = True,
        toolchain_config = ":{}".format(config),
        toolchain_identifier = "local",
        visibility = ["//toolchains:__pkg__"],
    )

    # Based on the output of:
    # CC=clang bazel query --output=build @local_config_cc//:local

    cc_toolchain_config(
        name = config,
        abi_libc_version = "local",
        abi_version = "local",
        compile_flags = [
            "-U_FORTIFY_SOURCE",
            # Using the stack protector breaks some builds.
            # See https://github.com/emscripten-core/emscripten/issues/9780.
            "-fno-stack-protector",
            "-Wall",
            "-Wthread-safety",
            "-Wself-assign",
            "-fcolor-diagnostics",
            "-fno-omit-frame-pointer",
        ],
        compiler = "clang",
        coverage_compile_flags = ["--coverage"],
        coverage_link_flags = ["--coverage"],
        cpu = cpu,
        cxx_builtin_include_directories = [],
        cxx_flags = ["-std=c++0x"],
        dbg_compile_flags = ["-g"],
        host_system_name = "local",
        link_flags = [
            "-fuse-ld=/usr/bin/ld.gold",
            "-Wl,-no-as-needed",
            "-Wl,-z,relro,-z,now",
            "-Bexternal/emscripten",
            "-lstdc++",
            "-lm",
        ],
        link_libs = [],
        opt_compile_flags = [
            "-g0",
            "-O2",
            "-D_FORTIFY_SOURCE=1",
            "-DNDEBUG",
            "-ffunction-sections",
            "-fdata-sections",
        ],
        opt_link_flags = ["-Wl,--gc-sections"],
        supports_start_end_lib = True,
        target_libc = "local",
        target_system_name = "local",
        tool_paths = {
            # Emscripten tools:
            "ar": "external/emscripten/emar",
            "cpp": "external/emscripten/em++",
            "gcc": "external/emscripten/emcc",

            # LLVM tools:
            "dwp": "external/llvm/bin/llvm-dwp",
            "nm": "external/llvm/bin/llvm-nm",
            "objcopy": "external/llvm/bin/llvm-objcopy",
            "objdump": "external/llvm/bin/llvm-objdump",
            "strip": "external/llvm/bin/llvm-strip",

            # System tools:
            "gcov": "/usr/bin/gcov",
            "ld": "/usr/bin/ld",
        },
        toolchain_identifier = "local",
        unfiltered_compile_flags = [
            "-no-canonical-prefixes",
            "-Wno-builtin-macro-redefined",
            "-D__DATE__=\"redacted\"",
            "-D__TIMESTAMP__=\"redacted\"",
            "-D__TIME__=\"redacted\"",
        ],
    )
