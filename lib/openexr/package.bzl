"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "dep_spec", "library_path", "major_minor", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "openexr"
VERSION = "3.1.5"
SHA256 = "93925805c1fc4f8162b35f0ae109c4a75344e6decae5a240afdfce25f8a433ec"

URL = "https://github.com/AcademySoftwareFoundation/{name}/archive/refs/tags/v{version}.tar.gz"

LNAME = "OpenEXR"

STATIC_LIBS = [static_lib("-".join([
    lib,
    major_minor(VERSION, join = "_"),
])) for lib in [
    LNAME,
    LNAME + "Core",
    LNAME + "Util",
    "Iex",
    "IlmThread",
]]

SPEC = dep_spec(
    name = NAME,
    library = library_path(NAME, STATIC_LIBS[0]),
)

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
