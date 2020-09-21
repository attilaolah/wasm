load("//:http_archive.bzl", "http_archive")
load("//toolchains/make:env_vars.bzl", "EMCONFIGURE")

VERSION = "1.2.11"

URL = "https://downloads.sourceforge.net/libpng/zlib-{version}.tar.gz"

SHA256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1"

def download_z():
    http_archive(
        name = "lib_z",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "zlib-{version}",
        patch_cmds = EMCONFIGURE,
    )
