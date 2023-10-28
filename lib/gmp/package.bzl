"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "gmp"
VERSION = "6.3.0"
SHA256 = "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"
CID = "QmTkiPkmnCo7WSWRcsHYW6UzjJM5Rouj35yVwb3SMoo4Em"

URLS = [
    "https://{name}lib.org/download/{name}/{name}-{version}.tar.xz",
    "https://ftp.gnu.org/gnu/{name}/{name}-{version}.tar.xz",
    "https://cloudflare-ipfs.com/ipfs/" + CID + "/{name}-{version}.tar.xz",
    "https://ipfs.io/ipfs/" + CID + "/{name}-{version}.tar.xz",
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = URLS,
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
    )
