load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":http_archive.bzl", "http_archive")
load("//lib:package.bzl", "download_lib")

def register_dependencies():
    """Set up dependencies of THIS workspace."""
    _github_repository(
        project = "rules_foreign_cc",
        owner = "bazelbuild",
        commit = "ed95b95affecaa3ea3bf7bab3e0ab6aa847dfb06",
        shallow_since = "1599808059 +0200",
    )

    http_archive(
        name = "platforms",
        version = "0.0.1",
        urls = ["https://github.com/bazelbuild/{name}/archive/{version}.tar.gz"],
        sha256 = "0fc19efca1dfc5c1448c98f050639e3a48beb0031701d55bea5eb546507970f2",
        strip_prefix = "{name}-{version}",
    )

    http_archive(
        name = "emscripten",
        version = "2.0.4",
        urls = ["https://github.com/{name}-core/{name}/archive/{version}.tar.gz"],
        sha256 = "f450aacf98cf5d70672452bbbb42ac41d51468f756c33414ce16b7cfc25ac699",
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
