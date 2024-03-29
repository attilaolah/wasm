workspace(name = "wasm")

## Workspace dependencies & toolchains.

load("//:versions.bzl", "GO_VERSION", "RUBY_VERSION")
load("//:workspace.bzl", "workspace_dependencies")

workspace_dependencies()

register_toolchains("//toolchains/cc:all")

## Go dependencies & toolchain.

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("//:deps.bzl", "external_dependencies", "go_dependencies")

go_rules_dependencies()

go_register_toolchains(version = GO_VERSION)

# gazelle:repository_macro deps.bzl%go_dependencies
go_dependencies()

## Protobuf dependencies.

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

## Gazelle dependencies.

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

# gazelle:repo bazel_gazelle
gazelle_dependencies()

## C/C++ dependencies (external). Provides @emsdk.

external_dependencies()

## Ruby dependencies.

load("@bazelruby_rules_ruby//ruby:deps.bzl", "rules_ruby_dependencies", "rules_ruby_select_sdk")

rules_ruby_dependencies()

rules_ruby_select_sdk(version = RUBY_VERSION)

load("@bazelruby_rules_ruby//ruby:defs.bzl", "ruby_bundle")

ruby_bundle(
    name = "bundle",
    gemfile = "//:Gemfile",
    gemfile_lock = "//:Gemfile.lock",
)

# Rust dependencies.

load("@rules_rust//bindgen:repositories.bzl", "rust_bindgen_dependencies", "rust_bindgen_register_toolchains")
load("@rules_rust//crate_universe:repositories.bzl", "crate_universe_dependencies")
load("@rules_rust//rust:repositories.bzl", "rules_rust_dependencies", "rust_register_toolchains")
load("@rules_rust//tools/rust_analyzer:deps.bzl", "rust_analyzer_dependencies")
load("@rules_rust//wasm_bindgen:repositories.bzl", "rust_wasm_bindgen_repositories")

rules_rust_dependencies()

rust_register_toolchains(edition = "2021")

crate_universe_dependencies(bootstrap = True)

rust_analyzer_dependencies()

rust_bindgen_dependencies()

rust_bindgen_register_toolchains()

rust_wasm_bindgen_repositories()

load("@rules_rust//crate_universe:defs.bzl", "crates_repository")

crates_repository(
    name = "crate_index",
    cargo_lockfile = "//:Cargo.lock",
    lockfile = "//:Cargo.bazel.lock",
    manifests = ["//:Cargo.toml"],
)

load("@crate_index//:defs.bzl", "crate_repositories")

crate_repositories()

## Skylib dependencies.

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

## Node dependencies & toolchain.

load("@build_bazel_rules_nodejs//:index.bzl", "node_repositories", "npm_install")
load("@build_bazel_rules_nodejs//:repositories.bzl", "build_bazel_rules_nodejs_dependencies")
load("@rules_nodejs//nodejs:repositories.bzl", "DEFAULT_NODE_VERSION", "nodejs_register_toolchains")

build_bazel_rules_nodejs_dependencies()

node_repositories()

npm_install(
    name = "npm",
    package_json = "//:package.json",
    package_lock_json = "//:package-lock.json",
)

nodejs_register_toolchains(
    name = "node",
    node_version = DEFAULT_NODE_VERSION,
)

## Webpack dependencies.

load("@aspect_rules_webpack//webpack:dependencies.bzl", "rules_webpack_dependencies")

rules_webpack_dependencies()

load("@aspect_rules_webpack//webpack:repositories.bzl", "webpack_repositories")

webpack_repositories(name = "webpack")

load("@webpack//:npm_repositories.bzl", webpack_npm_repositories = "npm_repositories")

webpack_npm_repositories()

## Emscripten SDK & dependencies.

load("@emsdk//:deps.bzl", emsdk_deps = "deps")

emsdk_deps()

load("@emsdk//:emscripten_deps.bzl", emsdk_emscripten_deps = "emscripten_deps")

emsdk_emscripten_deps()

## Sass dependencies.

load("@io_bazel_rules_sass//:defs.bzl", "sass_repositories")

sass_repositories()

## Closure dependencies & toolchains.

load("@io_bazel_rules_closure//closure:repositories.bzl", "rules_closure_dependencies", "rules_closure_toolchains")

rules_closure_dependencies()

rules_closure_toolchains()

## Packaging rules dependencies.

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")

rules_pkg_dependencies()
