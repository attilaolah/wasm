load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":http_archive.bzl", "http_archive")
load("//lib:package.bzl", "download_lib")
load("//tools:package.bzl", "download_tools")

def register_dependencies():
    """Set up dependencies of THIS workspace."""
    _github_repository(
        project = "rules_foreign_cc",
        owner = "bazelbuild",
        commit = "466c32c70f6262f43eac06ad5e9dc2cbecbba228",
        shallow_since = "1612531747 +0000",
        pull_requests = {
            481: "ee6536a9cec2844197b2cf4d9476a7be3bb43d99c3ec2231b5833bb17fe5f909",
        },
    )

    http_archive(
        name = "build_bazel_rules_nodejs",
        version = "3.0.0",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/{version}/rules_nodejs-{version}.tar.gz"],
        sha256 = "6142e9586162b179fdd570a55e50d1332e7d9c030efd853453438d607569721d",
        build_file_content = None,
    )

    http_archive(
        name = "platforms",
        version = "0.0.2",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
            "https://github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
        ],
        sha256 = "48a2d8d343863989c232843e01afc8a986eb8738766bfd8611420a7db8f6f0c3",
        build_file_content = None,
    )

    http_archive(
        name = "bazel-skylib",
        version = "1.0.3",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
            "https://github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
        ],
        sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
        build_file_content = None,
    )

    http_archive(
        name = "llvm",
        version = "11.0.1",
        urls = ["https://github.com/{name}/{name}-project/releases/download/{name}org-{version}/clang+{name}-{version}-x86_64-linux-gnu-ubuntu-20.10.tar.xz"],
        sha256 = "b60f68581182ace5f7d4a72e5cce61c01adc88050acb72b2070ad298c25071bc",
        strip_prefix = "clang+{name}-{version}-x86_64-linux-gnu-ubuntu-20.10",
    )

    em_version = "2.0.13"

    http_archive(
        name = "emsdk",
        version = em_version,
        urls = ["https://github.com/{name}-core/emsdk/archive/{version}.tar.gz"],
        sha256 = "1bacabdfa07e8565f269e99bcdfa13bf832d6fa64a784a40114deaca45572542",
        strip_prefix = "emsdk-{version}/bazel",
        build_file_content = None,
        patches = ["//tools/emscripten:emsdk.patch"],
    )

    http_archive(
        name = "emscripten",
        version = em_version,
        urls = ["https://storage.googleapis.com/webassembly/emscripten-releases-builds/linux/ce0e4a4d1cab395ee5082a60ebb4f3891a94b256/wasm-binaries.tbz2"],
        sha256 = "8986ed886e111c661099c5147126b8a379a4040aab6a1f572fe01f0f9b99a343",
        strip_prefix = "install",
        build_file = "@emsdk//emscripten_toolchain:emscripten.BUILD",
        build_file_content = None,
        patch_cmds = [
            # Remove files containing whitespace,
            # Otherwise they cause issues when symlinking sh_binary() runfiles.
            "rm -r emscripten/third_party/websockify/Windows",
        ],
        type = "tar.bz2",
    )

def register_repositories():
    """Fetch and set up dependencies."""
    download_lib()
    download_tools()

def _github_repository(project, owner, commit, shallow_since, pull_requests = None):
    """Wrapper around git_repository() for GitHub."""
    name = project.replace("-", "_")
    remote = "https://github.com/{}/{}".format(owner, project)

    patches, patch_args = [], []
    for pr, sha256 in (pull_requests or {}).items():
        pr_name = "{}_pr_{}".format(name, pr)
        patches.append("@{}//file:{}.patch".format(pr_name, pr))
        patch_args = ["-p1"]

        http_file(
            name = pr_name,
            downloaded_file_path = "{}.patch".format(pr),
            urls = ["{}/pull/{}.patch".format(remote, pr)],
            sha256 = sha256,
        )

    git_repository(
        name = name,
        remote = "https://github.com/{}/{}".format(owner, project),
        commit = commit,
        shallow_since = shallow_since,
        patches = patches,
        patch_args = patch_args,
    )
