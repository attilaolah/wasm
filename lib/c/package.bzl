"""Dummy file for defining glibc version and URLs.

As of now, this package doesn't actually build glibc, since it doesn't build
even build with LLVM+Clang at the moment: it requires __GNUC__ > 6, but Clang
defines __GNUC__ == 4.

Instead, the version listed below is built manually (for now), for the purpose
of generating the corresponding symbol tables for dependency resolution.
"""

VERSION = "2.33"

URLS = [
    "https://ftp.gnu.org/gnu/libc/glibc-{version}.tar.xz",
    "https://mirror.kumi.systems/gnu/libc/glibc-{version}.tar.xz",
]
