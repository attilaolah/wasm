workspace(name = "wasm")

load("//:package.bzl", "register_dependencies", "register_repositories")

register_dependencies()

register_repositories()

load("@rules_foreign_cc//:workspace_definitions.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies(
    native_tools_toolchains = [
        # Build cmake/ninja:
        #"//toolchains/cmake",
        #"//toolchains/ninja",

        # Use system cmake/ninja:
        "//toolchains/cmake:preinstalled",
        "//toolchains/ninja:preinstalled",
    ],
    register_default_tools = False,
)
