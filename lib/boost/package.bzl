"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "boost"
VERSION = "1.80.0"
SHA256 = "1e19565d82e43bc59209a168f5ac899d3ba471d55c7610c677d4ccf2c9c500c0"

URL = "https://boostorg.jfrog.io/artifactory/main/release/{version}/source/{name}_{version_}.tar.bz2"

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
        strip_prefix = "{name}_{version_}",
        patch_cmds = [
            # Remove test files with Non-ASCII names.
            # These produce Bazel warnings, and we don't use them anyway.
            "rm -r libs/wave/test/testwave/testfiles/utf8-test-*",
        ],
    )
