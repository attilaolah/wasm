load("//:http_archive.bzl", "http_archive")
load("//toolchains/make:configure.bzl", "EMCONFIGURE")

VERSION = "1.6.37"

URL = "https://downloads.sourceforge.net/libpng/libpng-{version}.tar.gz"

SHA256 = "daeb2620d829575513e35fecc83f0d3791a620b9b93d800b763542ece9390fb4"

def download_png():
    http_archive(
        name = "lib_png",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "libpng-{version}",
        patch_cmds = EMCONFIGURE,
    )
