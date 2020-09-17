workspace(name = "wasm")

load("//:package.bzl", "register_dependencies", "register_repositories")

register_dependencies()

register_repositories()

load("@rules_foreign_cc//:workspace_definitions.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies(
    native_tools_toolchains = [
        "//toolchains/cmake",
        "//toolchains/make",
    ],
    register_default_tools = True,
)
