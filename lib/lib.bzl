load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("//tools:version_info.bzl", "version_info")

_GH_URL = "https://github.com/{owner}/{repo}/{subdir}"
_GH_RELEASE_REGEX = r'<include-fragment loading="lazy" src="{release_url}/expanded_assets/{prefix}([^"]+)" data-test-selector="lazy-asset-list-fragment">'
_GH_TAG_REGEX = '<a href="/{owner}/{repo}/releases/tag/{prefix}([^"]+)">'

def package_lib(
    runtime_for = (),
    version_url = None,
    version_regex = None,
    github_release = None,
    github_tag = None,
    github_version_prefix = 'v',
):
    """Common package contents for most packages under //lib."""
    bzl_library(
        name = "package",
        srcs = ["package.bzl"],
        deps = [
            "//lib:defs",
            "//lib:http_archive",
        ],
    )

    for label in runtime_for:
        name = "runtime"
        if len(runtime_for) > 1:
            name = "_".join((label, name))
        native.filegroup(
            name = name,
            srcs = [":{}".format(label)],
            output_group = "gen_dir",
        )

    if github_release and github_tag:
        fail("only one of github_release or github_tag can be provided")

    if github_release == True:
        github_release = '{name}'
    if github_tag == True:
        github_tag = '{name}'

    gh_params = None
    if github_release:
        if type(github_release) == type(''):
            # Only the project nave mas passed, expand to user, project.
            github_release = (github_release, github_release)
        if len(github_release) != 2:
            fail("invalid github_release: {}".format(github_release))
        gh_params = {
            'owner': github_release[0],
            'repo': github_release[1],
            'subdir': 'releases',
        }
    elif github_tag:
        if type(github_tag) == type(''):
            # Only the project nave mas passed, expand to user, project.
            github_tag = (github_tag, github_tag)
        if len(github_tag) != 2:
            fail("invalid github_tag: {}".format(github_tag))
        gh_params = {
            'owner': github_tag[0],
            'repo': github_tag[1],
            'subdir': 'tags',
        }
    if gh_params:
        version_url = _GH_URL.format(**gh_params)
    if github_release:
        version_regex = _GH_RELEASE_REGEX.format(
            release_url = version_url,
            prefix = github_version_prefix,
        )
    elif github_tag:
        version_regex = '<a href="/{owner}/{repo}/releases/tag/{prefix}([^"]+)">'.format(
            prefix = github_version_prefix,
            **gh_params,
        )

    if version_url != None and version_regex != None:
        name = native.package_name().split('/')[-1]
        params = {
            'name': name,
            'tname': name.title(),
            'uname': name.upper(),
        }
        version_info(
            version_url = version_url.format(**params),
            version_regex = version_regex.format(**params),
        )
