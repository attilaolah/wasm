"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")
load("//tools/emscripten:emconfigure.bzl", "EMCONFIGURE")

VERSION = "4.1.0"

URLS = [
    "https://www.mpfr.org/mpfr-current/mpfr-{version}.tar.xz",
    "https://ftp.gnu.org/gnu/mpfr/mpfr-{version}.tar.xz",
]

SHA256 = "0c98a3f1732ff6ca4ea690552079da9c597872d30e96ec28414ee23c95558a7f"

def download_mpfr():
    http_archive(
        name = "lib_mpfr",
        version = VERSION,
        urls = URLS,
        sha256 = SHA256,
        strip_prefix = "mpfr-{version}",
        patch_cmds = EMCONFIGURE,
    )
