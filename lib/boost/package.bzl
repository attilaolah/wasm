"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")
load("//lib:defs.bzl", "static_lib")

NAME = "boost"
VERSION = "1.77.0"

URL = "https://boostorg.jfrog.io/ui/api/v1/download?repoKey=main&path=release/{version}/source/{name}_{version_}.tar.gz"

SHA256 = "5347464af5b14ac54bb945dc68f1dd7c56f0dad7262816b956138fc53bcc0131"

STATIC_LIBS = [static_lib("_".join([NAME, lib])) for lib in [
    # keep sorted
    "atomic",
    "chrono",
    "container",
    "context",
    "contract",
    "coroutine",
    "date_time",
    "exception",
    "fiber",
    "filesystem",
    "graph",
    "iostreams",
    "json",
    "locale",
    "log",
    "log_setup",
    "math_c99",
    "math_c99f",
    "math_c99l",
    "math_tr1",
    "math_tr1f",
    "math_tr1l",
    "nowide",
    "prg_exec_monitor",
    "program_options",
    "random",
    "regex",
    "serialization",
    "stacktrace_addr2line",
    "stacktrace_backtrace",
    "stacktrace_basic",
    "stacktrace_noop",
    "system",
    "test_exec_monitor",
    "thread",
    "timer",
    "type_erasure",
    "unit_test_framework",
    "wave",
    "wserialization",
]]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        type = "tar.gz",
        strip_prefix = "{name}_{version_}",
        patch_cmds = [
            # Remove files with Non-ASCII names to prevent Bazel from freaking out.
            "rm -r libs/wave/test/testwave/testfiles/utf8-test-*",
        ],
    )
