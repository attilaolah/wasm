"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "dep_spec", "library_path", "major_minor", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "openexr"
VERSION = "3.1.4"

URL = "https://github.com/AcademySoftwareFoundation/{name}/archive/refs/tags/v{version}.tar.gz"

SHA256 = "cb019c3c69ada47fe340f7fa6c8b863ca0515804dc60bdb25c942c1da886930b"

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
