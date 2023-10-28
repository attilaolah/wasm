"""Workspace rule for downloading package dependencies."""

load("//lib:http_archive.bzl", "http_archive")

NAME = "mpfr"
VERSION = "4.2.1"
SHA256 = "277807353a6726978996945af13e52829e3abd7a9a5b7fb2793894e18f1fcbb2"
CID = "QmTeJb9zL3sTTgXE352SbWhPpuz5Po9Q6dQ4KYj9brSWvr"

URLS = [
    "https://www.{name}.org/{name}-{version}/{name}-{version}.tar.xz",
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
