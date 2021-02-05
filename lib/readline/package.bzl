load("//:http_archive.bzl", "http_archive")
load("//tools/emscripten:emconfigure.bzl", "EMCONFIGURE")

VERSION = "8.0"

URL = "https://ftp.gnu.org/gnu/readline/readline-{version}.tar.gz"

SHA256 = "e339f51971478d369f8a053a330a190781acb9864cf4c541060f12078948e461"

def download_readline():
    http_archive(
        name = "lib_readline",
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "readline-{version}",
        patch_cmds = EMCONFIGURE,
    )
