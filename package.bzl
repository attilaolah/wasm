load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":http_archive.bzl", "ALL_PUBLIC", "http_archive")
load("//lib:package.bzl", "download_lib")
load("//tools:package.bzl", "download_tools")

def register_dependencies():
    """Set up dependencies of THIS workspace."""
    _github_repository(
        project = "rules_foreign_cc",
        owner = "bazelbuild",
        commit = "75e74567c76fa0dabf4cc5752af3b7cee7689704",
        shallow_since = "1611343471 +0000",
        pull_requests = {
            427: "fb02cb20a67252f46d64d03e67050030ccb8e653885ff4d415866c2e1d72d4ff",
            428: "b59b5d59b03232487730bc009b2d989245049de7020fabc857d0e0d1dd2b990d",
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
        name = "binaryen",
        version = "99",
        urls = ["https://github.com/WebAssembly/{name}/archive/version_{version}.tar.gz"],
        sha256 = "66ac4430367f2096466703b81749db836d8f4766e542b042d64e78b601372cf7",
        strip_prefix = "{name}-version_{version}",
    )

    http_archive(
        name = "emscripten",
        version = "2.0.12",
        urls = ["https://github.com/{name}-core/{name}/archive/{version}.tar.gz"],
        sha256 = "d9419c9ea6df4c9582a3a09fdeafec16f5f3c64866f6faf86989ea1ef99f54ea",
        strip_prefix = "{name}-{version}",
    )

    http_archive(
        name = "llvm",
        version = "11.0.1",
        urls = ["https://github.com/{name}/{name}-project/releases/download/{name}org-{version}/clang+{name}-{version}-x86_64-linux-gnu-ubuntu-20.10.tar.xz"],
        sha256 = "b60f68581182ace5f7d4a72e5cce61c01adc88050acb72b2070ad298c25071bc",
        strip_prefix = "clang+{name}-{version}-x86_64-linux-gnu-ubuntu-20.10",
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
