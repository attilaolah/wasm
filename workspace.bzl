"""Repository rules for downloading all dependencies."""

load("//toolchains:utils.bzl", "patch_files")
load("//tools:javascript_target.bzl", "JS_TARGET")
load(":http_archive.bzl", "http_archive")

def workspace_dependencies():
    """Set up dependencies of THIS workspace."""
    http_archive(
        name = "build_bazel_rules_nodejs",
        version = "5.5.3",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/{version}/rules_nodejs-{version}.tar.gz"],
        sha256 = "f10a3a12894fc3c9bf578ee5a5691769f6805c4be84359681a785a0c12e8d2b6",
        build_file_content = None,
    )

    http_archive(
        name = "platforms",
        version = "0.0.6",
        urls = [
            "https://github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
        ],
        sha256 = "5308fc1d8865406a49427ba24a9ab53087f17f5266a7aabbfc28823f3916e1ca",
        build_file_content = None,
    )

    http_archive(
        name = "bazel-skylib",
        version = "1.4.0",
        urls = [
            "https://github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
        ],
        sha256 = "f24ab666394232f834f74d19e2ff142b0af17466ea0c69a3f4c276ee75f6efce",
        build_file_content = None,
    )

    http_archive(
        name = "com_google_protobuf",
        version = "3.19.4",  # This should match VERSION from //lib/protobuf:package.bzl.
        urls = ["https://github.com/protocolbuffers/protobuf/archive/v3.19.4.tar.gz"],
        sha256 = "3bd7828aa5af4b13b99c191e8b1e884ebfa9ad371b0ce264605d347f135d2568",
        strip_prefix = "protobuf-{version}",
        build_file_content = None,
    )

    http_archive(
        name = "com_github_bazelbuild_buildtools",
        version = "4.2.2",
        urls = ["https://github.com/bazelbuild/buildtools/archive/refs/tags/{version}.tar.gz"],
        sha256 = "ae34c344514e08c23e90da0e2d6cb700fcd28e80c02e23e4d5715dddcb42f7b3",
        strip_prefix = "buildtools-{version}",
        build_file_content = None,
    )

    http_archive(
        name = "io_bazel_rules_sass",
        version = "1.54.9",
        urls = ["https://github.com/bazelbuild/rules_sass/archive/refs/tags/{version}.tar.gz"],
        strip_prefix = "rules_sass-{version}",
        sha256 = "8153959858eb898a8eca9f4408f0287c73bfdb85f048a14a8a271fe12b780433",
        build_file_content = None,
    )

    http_archive(
        name = "io_bazel_rules_closure",
        version = "f19dc96c1dad6990b67dc3a35818cde5b7042bbb",  # master @ 2023-10-18T23:57:51Z
        sha256 = "1ca3e1014e85077ccf0b1399b69b0a741560660dc47638f38bd4dcb0c8e2122d",
        strip_prefix = "rules_closure-{version}",
        urls = ["https://github.com/bazelbuild/rules_closure/archive/{version}.zip"],
        patch_cmds = patch_files({
            "closure/private/defs.bzl": 's/JS_LANGUAGE_IN = "STABLE"/JS_LANGUAGE_IN = "{}"/'.format(JS_TARGET),
        }),
    )

    http_archive(
        name = "aspect_rules_webpack",
        version = "0.6.1",
        sha256 = "c7ccb778a24ec7033ab796e4b480153299b7ff0d75e64a957824055f201fa2af",
        strip_prefix = "rules_webpack-{version}",
        urls = ["https://github.com/aspect-build/rules_webpack/archive/refs/tags/v{version}.tar.gz"],
    )

    http_archive(
        name = "rules_rust",
        version = "0.29.1",
        sha256 = "9ecd0f2144f0a24e6bc71ebcc50a1ee5128cedeceb32187004532c9710cb2334",
        urls = ["https://github.com/bazelbuild/rules_rust/releases/download/{version}/rules_rust-v{version}.tar.gz"],
        build_file_content = None,
    )

    http_archive(
        name = "rules_pkg",
        version = "0.8.0",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/{version}/rules_pkg-{version}.tar.gz",
            "https://github.com/bazelbuild/rules_pkg/releases/download/{version}/rules_pkg-{version}.tar.gz",
        ],
        sha256 = "eea0f59c28a9241156a47d7a8e32db9122f3d50b505fae0f33de6ce4d9b61834",
        build_file_content = None,
    )
