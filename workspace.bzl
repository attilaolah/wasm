"""Repository rules for downloading all dependencies."""

load(":http_archive.bzl", "http_archive")
load("//notebook/style:themes/mdn_yari.bzl", download_mdn_yari = "download")
load("//tools:javascript_target.bzl", "JS_TARGET")
load("//toolchains:utils.bzl", "patch_files")

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
        version = "5.5.3",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/{version}/rules_nodejs-{version}.tar.gz"],
        sha256 = "f10a3a12894fc3c9bf578ee5a5691769f6805c4be84359681a785a0c12e8d2b6",
        build_file_content = None,
    )

    http_archive(
        name = "io_bazel_rules_go",
        version = "0.35.0",
        urls = [
            "https://github.com/bazelbuild/rules_go/releases/download/v{version}/rules_go-v{version}.zip",
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v{version}/rules_go-v{version}.zip",
        ],
        sha256 = "099a9fb96a376ccbbb7d291ed4ecbdfd42f6bc822ab77ae6f1b5cb9e914e94fa",
        build_file_content = None,
    )

    http_archive(
        name = "bazel_gazelle",
        version = "0.27.0",
        urls = [
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v{version}/bazel-gazelle-v{version}.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v{version}/bazel-gazelle-v{version}.tar.gz",
        ],
        sha256 = "efbbba6ac1a4fd342d5122cbdfdb82aeb2cf2862e35022c752eaddffada7c3f3",
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
        version = "1d8c08055488d15c4eaa7e70f9bdfba1b2c83b5b",  # master @ 2022-03-25T23:36:15Z
        sha256 = "6032db43d2ce09570a0de94b3a2b5e24654a9232c45e0d418b5314867adf4173",
        strip_prefix = "rules_closure-{version}",
        urls = ["https://github.com/bazelbuild/rules_closure/archive/{version}.zip"],
        patch_cmds = patch_files({
            "closure/private/defs.bzl": 's/JS_LANGUAGE_IN = "STABLE"/JS_LANGUAGE_IN = "{}"/'.format(JS_TARGET),
        }),
    )

    http_archive(
        name = "bazelruby_rules_ruby",
        version = "c93a6814b6193572c7c8b677b560314f52b31962",  # master @ 2022-04-29T20:36:44Z
        sha256 = "21eb494757d8062eaf699bc85e0aa29bcf851268ff78d23737967099e5bb9417",
        strip_prefix = "rules_ruby-{version}",
        urls = ["https://github.com/bazelruby/rules_ruby/archive/{version}.zip"],
    )

    download_mdn_yari()
