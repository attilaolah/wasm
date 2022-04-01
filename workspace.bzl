"""Repository rules for downloading all dependencies."""

load(":http_archive.bzl", "http_archive")

def workspace_dependencies():
    """Set up dependencies of THIS workspace."""
    http_archive(
        name = "rules_foreign_cc",
        version = "9fc3411bb506de1e0d1fa91db0dbf7712d1028ae",
        urls = ["https://github.com/bazelbuild/{name}/archive/{version}.tar.gz"],
        sha256 = "0163c5a8ea65e8b100933b8ad1436d928e2107672c06732599f04174aa2afd5a",
        strip_prefix = "{name}-{version}",
        build_file_content = None,
    )

    http_archive(
        name = "build_bazel_rules_nodejs",
        version = "5.3.1",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/{version}/rules_nodejs-{version}.tar.gz"],
        sha256 = "523da2d6b50bc00eaf14b00ed28b1a366b3ab456e14131e9812558b26599125c",
        build_file_content = None,
    )

    http_archive(
        name = "io_bazel_rules_go",
        version = "0.31.0",
        urls = [
            "https://github.com/bazelbuild/rules_go/releases/download/v{version}/rules_go-v{version}.zip",
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v{version}/rules_go-v{version}.zip",
        ],
        sha256 = "f2dcd210c7095febe54b804bb1cd3a58fe8435a909db2ec04e31542631cf715c",
        build_file_content = None,
    )

    http_archive(
        name = "bazel_gazelle",
        version = "0.25.0",
        urls = [
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v{version}/bazel-gazelle-v{version}.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v{version}/bazel-gazelle-v{version}.tar.gz",
        ],
        sha256 = "5982e5463f171da99e3bdaeff8c0f48283a7a5f396ec5282910b9e8a49c0dd7e",
        build_file_content = None,
    )

    http_archive(
        name = "platforms",
        version = "0.0.3",
        urls = [
            "https://github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
        ],
        sha256 = "460caee0fa583b908c622913334ec3c1b842572b9c23cf0d3da0c2543a1a157d",
        build_file_content = None,
    )

    http_archive(
        name = "bazel-skylib",
        version = "1.2.1",
        urls = [
            "https://github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
        ],
        sha256 = "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
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
