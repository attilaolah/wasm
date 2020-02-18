load("//:http_archive.bzl", "http_archive")

NAME = "libpano13"
VERSION = "2.9.19"

URL = "https://download.sourceforge.net/panotools/{name}-{version}.tar.gz"

SHA256 = "037357383978341dea8f572a5d2a0876c5ab0a83dffda431bd393357e91d95a8"

def download_src():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = ["CMakeLists.txt.patch"],
        patch_cmds = [
            "chmod +x bootstrap",
        ],
    )
