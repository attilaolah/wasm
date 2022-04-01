"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "dep_spec", "library_path", "major", "static_lib")

NAME = "sqlite"
VERSION = "3.35.5"

URL = "https://www.{name}.org/2021/{name}-autoconf-3350500.tar.gz"

SHA256 = "f52b72a5c319c3e516ed7a92e123139a6e87af08a2dc43d7757724f6132e6db0"

BINARIES = [NAME + major(VERSION)]

STATIC_LIBS = [static_lib(binary) for binary in BINARIES]

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
        strip_prefix = "{name}-autoconf-3350500",
    )
