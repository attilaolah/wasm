load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":http_archive.bzl", "ALL_PUBLIC", "http_archive")
load("//lib:package.bzl", "download_lib")

def register_dependencies():
    """Set up dependencies of THIS workspace."""
    _github_repository(
        project = "rules_foreign_cc",
        owner = "bazelbuild",
        commit = "d54c78ab86b40770ee19f0949db9d74a831ab9f0",
        shallow_since = "1603722361 +0100",
        pull_requests = {
            427: "82697ff6a3eb5ab25e2093ca4cf378bba4de7a2eadf149b7e3917f9d47c4564c",
            428: "5bb7433097fd79424b1cad5484bd609535462b14d9122b1dc8c23a31582ad808",
        },
    )

    http_archive(
        name = "build_bazel_rules_nodejs",
        version = "2.2.0",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/{version}/rules_nodejs-{version}.tar.gz"],
        sha256 = "4952ef879704ab4ad6729a29007e7094aef213ea79e9f2e94cbe1c9a753e63ef",
        build_file_content = None,
    )

    http_archive(
        name = "platforms",
        version = "0.0.1",
        urls = ["https://github.com/bazelbuild/{name}/archive/{version}.tar.gz"],
        sha256 = "0fc19efca1dfc5c1448c98f050639e3a48beb0031701d55bea5eb546507970f2",
        strip_prefix = "{name}-{version}",
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
        name = "binaryen",
        version = "98",
        urls = ["https://github.com/WebAssembly/{name}/archive/version_{version}.tar.gz"],
        sha256 = "9f805db6735869ab52cde7c0404879c90cf386888c0f587e944737550171c1c4",
        strip_prefix = "{name}-version_{version}",
    )

    http_archive(
        name = "emscripten",
        version = "2.0.8",
        urls = ["https://github.com/{name}-core/{name}/archive/{version}.tar.gz"],
        sha256 = "609a7ecea954821efbcc55bf5ad88dd03ba4f836c703b8ad2e37c243329174a6",
        strip_prefix = "{name}-{version}",
    )

    http_archive(
        name = "llvm",
        version = "11.0.0",
        urls = ["https://github.com/{name}/{name}-project/releases/download/{name}org-{version}/clang+{name}-{version}-x86_64-linux-gnu-ubuntu-20.04.tar.xz"],
        sha256 = "829f5fb0ebda1d8716464394f97d5475d465ddc7bea2879c0601316b611ff6db",
        strip_prefix = "clang+{name}-{version}-x86_64-linux-gnu-ubuntu-20.04",
    )

def register_repositories():
    """Fetch and set up dependencies."""
    download_lib()

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
