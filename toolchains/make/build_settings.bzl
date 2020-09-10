MakeToolchainProvider = provider(fields = ["toolchain"])

MAKE_TOOLCHAINS = [
    "make",
    "make_preinstalled",
    "emmake_preinstalled",
]

def _make_toolchain_impl(ctx):
    toolchain = ctx.build_setting_value
    if toolchain not in MAKE_TOOLCHAINS:
        fail("{label} build setting must be one of {{{values}}}".format(
            label = ctx.label,
            values = ", ".join(MAKE_TOOLCHAINS),
        ))
    return MakeToolchainProvider(toolchain = toolchain)

make_toolchain = rule(
    implementation = _make_toolchain_impl,
    build_setting = config.string(flag = True),
)
