"""Clang toolchain implementation.

CUrrently only includes a Linux-based X86_64 LLVM+Clang based toolchain, based
on the downloaded bineries in @llvm.
"""

load("@local_config_cc//:cc_toolchain_config.bzl", "cc_toolchain_config")
load("@rules_cc//cc:defs.bzl", "cc_toolchain")

LINUX_X86_64 = [
    "@platforms//os:linux",
    "@platforms//cpu:x86_64",
]

LLVM_PATH = "external/llvm"

def clang_toolchain(name):
    """LLVM+Clang toolchain.

    Args:
      name: Name of the toolchain. Should be platform-specific, e.g.
        "linux_x86_64_clang".
    """
    name_cc_toolchain = "{}_cc_toolchain".format(name)
    name_cc_toolchain_config = "{}_config".format(name_cc_toolchain)

    native.toolchain(
        name = name,
        exec_compatible_with = LINUX_X86_64,
        target_compatible_with = LINUX_X86_64,
        toolchain = name_cc_toolchain,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )

    # Based on the output of:
    # CC=clang bazel query --output=build @local_config_cc//:cc-compiler-k8
    cc_toolchain(
        name = name_cc_toolchain,
        all_files = "@llvm//:all",
        ar_files = "@llvm//:all",
        as_files = "@llvm//:all",
        compiler_files = "@llvm//:all",
        dwp_files = "@llvm//:all",
        linker_files = "@llvm//:all",
        objcopy_files = "@llvm//:all",
        strip_files = "@llvm//:all",
        supports_param_files = True,
        toolchain_config = ":{}".format(name_cc_toolchain_config),
        toolchain_identifier = "local",
        visibility = ["//toolchains:__pkg__"],

        # NOTE: The original module map would be:
        # module_map = "@local_config_cc//:module.modulemap",
        # However, it is only generated when auto-configuring with CC=clang.
    )

    llvm_bin = "{}/bin".format(LLVM_PATH)

    # LLVM tools prefixed with "llvm-":
    tool_paths = {
        tool: "{}/llvm-{}".format(llvm_bin, tool)
        for tool in ["ar", "dwp", "nm", "objcopy", "objdump", "strip"]
    }

    # Special-case these tools that don't match the above pattern:
    for tool, llvm_tool in {
        "cpp": "clang++",
        "gcc": "clang",
        "gcov": "llvm-cov",
        "ld": "ld.lld",
        "llvm-cov": "llvm-cov",
    }.items():
        tool_paths.setdefault(tool, "{}/{}".format(llvm_bin, llvm_tool))

    # Additional compile flags, enabled by default for all targets:

    # Based on the output of:
    # CC=clang bazel query --output=build @local_config_cc//:local
    cc_toolchain_config(
        name = name_cc_toolchain_config,
        abi_libc_version = "local",
        abi_version = "local",
        compile_flags = [
            "-U_FORTIFY_SOURCE",
            "-Wall",
            "-Wthread-safety",
            "-Wself-assign",
            "-fcolor-diagnostics",
            "-fno-omit-frame-pointer",
            "-fstack-protector",
        ],
        compiler = "clang",
        coverage_compile_flags = ["--coverage"],
        coverage_link_flags = ["--coverage"],
        cpu = "k8",
        cxx_builtin_include_directories = [
            # TODO: Implement a sandboxed builtin_sysroot!
            "/usr/include",
        ],
        cxx_flags = ["-std=c++17"],
        dbg_compile_flags = ["-g"],
        host_system_name = "local",
        link_flags = [
            "-B{}/bin".format(LLVM_PATH),
            "--ld-path={}/bin/ld.lld".format(LLVM_PATH),
            "-Wl,-no-as-needed",
            "-Wl,-z,relro,-z,now",
            "-lstdc++",
            "-lm",

            # Make GCC and Clang do what we want when called through symlinks.
            "-no-canonical-prefixes",
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
        tool_paths = tool_paths,
        toolchain_identifier = "local",
        unfiltered_compile_flags = [
            # Make GCC and Clang do what we want when called through symlinks.
            "-no-canonical-prefixes",

            # Make C++ compilation deterministic.
            # Use linkstamping instead of these compiler symbols.
            # TODO: These lead to various escaping issues, breaking Python, HDF5 and Exiv2.
            # See: https://github.com/bazelbuild/rules_foreign_cc/issues/239
            #r"-D__DATE__=\"redacted\"",
            #r"-D__TIME__=\"redacted\"",
            #r"-D__TIMESTAMP__=\"redacted\"",
            #"-Wno-builtin-macro-redefined",
        ],
    )
