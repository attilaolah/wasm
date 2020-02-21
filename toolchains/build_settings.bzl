CMakeToolchainProvider = provider(fields = ["toolchain"])

CMAKE_TOOLCHAINS = [
    "//toolchains/cmake",
    "//toolchains/cmake:preinstalled",
    "//toolchains/emcmake:preinstalled",
]

def _cmake_toolchain_impl(ctx):
    toolchain = ctx.build_setting_value
    if toolchain not in CMAKE_TOOLCHAINS:
        fail("{label} build setting must be one of {{{values}}}".format(
            label = ctx.label,
            values = ", ".join(CMAKE_TOOLCHAINS),
        ))
    return CMakeToolchainProvider(toolchain = toolchain)

cmake_toolchain = rule(
    implementation = _cmake_toolchain_impl,
    build_setting = config.string(flag = True),
)
