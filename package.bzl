load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":http_archive.bzl", "http_archive")
load("//lib:package.bzl", "download_lib")

def register_dependencies():
    """Set up dependencies of THIS workspace."""
    _github_repository(
        project = "rules_foreign_cc",
        owner = "bazelbuild",
        commit = "9eb30f8c5a214799b73707666ca49e7b7a35978f",
        shallow_since = "1594651263 +0200"
    )

    http_archive(
        name = "cmake",
        version = "3.17.1",
        urls = ["https://github.com/Kitware/CMake/releases/download/v{version}/{name}-{version}.tar.gz"],
        sha256 = "3aa9114485da39cbd9665a0bfe986894a282d5f0882b1dea960a739496620727",
        strip_prefix = "{name}-{version}",
    )

    http_archive(
        name = "ninja",
        version = "1.10.0",
        urls = ["https://github.com/{name}-build/{name}/archive/v{version}.zip"],
        sha256 = "bb489516d71f6e9c01ae65ab177041e025736bfcb042ac037be9e298abfcb056",
        strip_prefix = "{name}-{version}",
    )

    http_archive(
        name = "bazel-skylib",
        version = "1.0.3",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
            "https://github.com/bazelbuild/{name}/releases/download/{version}/{name}-{version}.tar.gz",
        ],
        sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
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
