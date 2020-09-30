load("@local_config_cc//:cc_toolchain_config.bzl", "cc_toolchain_config")

LINUX_X86_64 = [
    "@platforms//os:linux",
    "@platforms//cpu:x86_64",
]

LLVM_TOOLS = [
    "dwp",
    "nm",
    "objcopy",
    "objdump",
    "strip",
]

TOOLS = LLVM_TOOLS + [
    "ar",
    "cpp",
    "gcc",
    "gcov",
    "ld",
]

def clang_toolchain():
    native.toolchain(
        name = "linux_x86_64_clang",
        exec_compatible_with = LINUX_X86_64,
        target_compatible_with = LINUX_X86_64,
        toolchain = "linux_x86_64_clang_cc_toolchain",
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )

    builtin_include_directory_paths = "builtin_include_directory_paths"

    # Based on the output of:
    # CC=clang bazel query --output=build @local_config_cc//:cc-compiler-k8
    clang_cc_toolchain(
        name = "linux_x86_64_clang_cc_toolchain",
        all_files = ":{}".format(builtin_include_directory_paths),
    )

    clang_cc_toolchain_config(
        name = "linux_x86_64_clang_cc_toolchain_config",
        cpu = "k8",
        stack_protector = True,
        cxx_builtin_include_directories = [
            "/usr/lib/llvm-9/lib/clang/9.0.1/include",
            "/usr/lib/llvm-9/lib/clang/9.0.1/share",
            "/usr/include/x86_64-linux-gnu/c++/9",
            "/usr/include/x86_64-linux-gnu",
            "/usr/include/c++/9",
            "/usr/include/c++/9/backward",
            "/usr/include",
        ],
        link_flags = [
            "-fuse-ld=/usr/bin/ld.gold",
            "-Wl,-no-as-needed",
            "-Wl,-z,relro,-z,now",
            "-B/usr/bin",
            "-lstdc++",
            "-lm",
        ],
        tool_paths = {
            "gcc": "/usr/bin/clang",
        },
    )

    native.filegroup(
        name = builtin_include_directory_paths,
        srcs = ["@local_config_cc//:{}".format(builtin_include_directory_paths)],
    )

def clang_cc_toolchain(name, all_files = "@local_config_cc//:empty"):
    # Based on the output of:
    # CC=clang bazel query --output=build @local_config_cc//:cc-compiler-k8
    native.cc_toolchain(
        name = name,
        all_files = all_files,
        ar_files = all_files,
        as_files = all_files,
        compiler_files = all_files,
        dwp_files = all_files,
        linker_files = all_files,
        objcopy_files = all_files,
        strip_files = all_files,
        supports_param_files = True,
        toolchain_config = ":{}_config".format(name),
        toolchain_identifier = "local",
        visibility = ["//toolchains:__pkg__"],

        # NOTE: The original module map would be:
        # module_map = "@local_config_cc//:module.modulemap",
        # However, it is only generated when auto-configuring with CC=clang.
    )

def clang_cc_toolchain_config(
        name,
        cpu,
        stack_protector = None,
        cxx_builtin_include_directories = None,
        link_flags = None,
        tool_paths = None):
    if cxx_builtin_include_directories == None:
        cxx_builtin_include_directories = []
    if link_flags == None:
        link_flags = []
    if tool_paths == None:
        tool_paths = {}
    for tool in TOOLS:
        tool_paths.setdefault(tool, "/usr/bin/{}".format(tool))

    compile_flags = [
        "-U_FORTIFY_SOURCE",
        "-Wall",
        "-Wthread-safety",
        "-Wself-assign",
        "-fcolor-diagnostics",
        "-fno-omit-frame-pointer",
    ]
    if stack_protector != None:
        _flag = "-f{}stack-protector".format("" if stack_protector else "no-")
        compile_flags.append(_flag)

    # Based on the output of:
    # CC=clang bazel query --output=build @local_config_cc//:local
    cc_toolchain_config(
        name = name,
        abi_libc_version = "local",
        abi_version = "local",
        compile_flags = compile_flags,
        compiler = "clang",
        coverage_compile_flags = ["--coverage"],
        coverage_link_flags = ["--coverage"],
        cpu = cpu,
        cxx_builtin_include_directories = cxx_builtin_include_directories,
        cxx_flags = ["-std=c++0x"],
        dbg_compile_flags = ["-g"],
        host_system_name = "local",
        link_flags = link_flags,
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
            "-no-canonical-prefixes",
            "-Wno-builtin-macro-redefined",

            # Make builds reproducible:
            '-D__DATE__="redacted"',
            '-D__TIME__="redacted"',
            '-D__TIMESTAMP__="redacted"',
        ],
    )
