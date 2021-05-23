# Declares that this directory is the root of a Bazel workspace.
# See https://docs.bazel.build/versions/master/build-ref.html#workspace
workspace(
    # How this workspace would be referenced with absolute labels from another workspace
    name = "wasm",
    # Map the @npm bazel workspace to the node_modules directory.
    # This lets Bazel use the same node_modules as other local tooling.
    managed_directories = {"@npm": ["node_modules"]},
)

load("//:workspace.bzl", "workspace_dependencies")

workspace_dependencies()

register_toolchains("//toolchains/cc:all")

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies(
    register_preinstalled_tools = False,
)

load("@build_bazel_rules_nodejs//:index.bzl", "npm_install")

npm_install(
    name = "npm",
    package_json = "//:package.json",
    package_lock_json = "//:package-lock.json",
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("//:deps.bzl", "external_dependencies", "go_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.16.2")

# gazelle:repo bazel_gazelle
gazelle_dependencies()

# gazelle:repository_macro deps.bzl%go_dependencies
go_dependencies()

external_dependencies()
