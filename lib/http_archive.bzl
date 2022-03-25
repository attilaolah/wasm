"""Custom http_archive() macro.

To b e used by library rules under //lib/... only.
"""

load("//:http_archive.bzl", _http_archive = "http_archive")
load("//lib:defs.bzl", _repo_name = "repo_name")

def http_archive(name, **kwargs):
    _http_archive(
        name = _repo_name(name),
        format_kwargs = {"name": name},
        **kwargs
    )
