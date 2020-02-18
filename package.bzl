load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//lib:package.bzl", "download_lib")
load("//libjpeg_turbo:package.bzl", download_libjpeg_turbo = "download_src")
load("//vigra:package.bzl", download_vigra = "download_src")
load(":http_archive.bzl", "http_archive")

def register_dependencies():
    """Set up dependencies of THIS workspace."""
    _github_repository(
        project = "rules_foreign_cc",
        owner = "bazelbuild",
        commit = "8b477ca9cb248fc472f152aa1a44c55ab71c4636",
        shallow_since = "1581586002 +0100",
        pull_requests = {
            358: "cb5d6d647daeaed0e66685d148e00063217e7e2553cbc4c9ca714ac8ca4c49e4",
        },
    )

    http_archive(
        name = "cmake",
        version = "3.16.4",
        urls = ["https://gitlab.kitware.com/{name}/{name}/-/archive/v{version}/{name}-v{version}.tar.bz2"],
        sha256 = "40e0dec6dc9e36820e001b8425aa4328a0b42f1915b14d68aee116e25c3d34df",
        strip_prefix = "{name}-v{version}",
    )

    http_archive(
        name = "ninja",
        version = "1.10.0",
        urls = ["https://github.com/{name}-build/{name}/archive/v{version}.zip"],
        sha256 = "bb489516d71f6e9c01ae65ab177041e025736bfcb042ac037be9e298abfcb056",
        strip_prefix = "{name}-{version}",
    )

    _github_repository(
        project = "bazel-skylib",
        owner = "bazelbuild",
        commit = "e59b620b392a8ebbcf25879fc3fde52b4dc77535",  # 1.0.2
        shallow_since = "1570639401 -0400",
    )

def register_repositories():
    """Fetch and set up dependencies."""
    download_lib()
    download_libjpeg_turbo()
    download_vigra()

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
