load("//:http_archive.bzl", "http_archive")
load("//toolchains/make:env_vars.bzl", "EMCONFIGURE")

VERSION = "6.2.0"

URL = "https://gmplib.org/download/gmp/gmp-{version}.tar.gz"

SHA256 = "cadd49052b740ccc3d8075c24ceaefbe5128d44246d91d0ecc818b2f78b0ec9c"

def download_gmp():
    http_archive(
        name = "lib_gmp",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "gmp-{version}",
        patch_cmds = EMCONFIGURE,
    )
