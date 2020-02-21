NinjaToolchainProvider = provider(fields = ["toolchain"])

NINJA_TOOLCHAINS = [
    "ninja",
    "ninja_preinstalled",
]

def _ninja_toolchain_impl(ctx):
    toolchain = ctx.build_setting_value
    if toolchain not in NINJA_TOOLCHAINS:
        fail("{label} build setting must be one of {{{values}}}".format(
            label = ctx.label,
            values = ", ".join(NINJA_TOOLCHAINS),
        ))
    return NinjaToolchainProvider(toolchain = toolchain)

ninja_toolchain = rule(
    implementation = _ninja_toolchain_impl,
    build_setting = config.string(flag = True),
)
