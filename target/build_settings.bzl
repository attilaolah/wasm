TargetProvider = provider(fields = ["target"])

TARGETS = [
    "default",
    "wasm",
]

def _target_impl(ctx):
    toolchain = ctx.build_setting_value
    if toolchain not in TARGETS:
        fail("{label} build setting must be one of {{{values}}}".format(
            label = ctx.label,
            values = ", ".join(TARGETS),
        ))
    return TargetProvider(target = target)

target = rule(
    implementation = _target_impl,
    build_setting = config.string(flag = True),
)

def config_settings():
    for target in TARGETS:
        native.config_setting(
            name = target,
            flag_values = {":target": target},
            visibility = ["//toolchains:__subpackages__"],
        )
