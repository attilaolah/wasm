"""Dummy file for defining libgcc version and URLs.

As of now, this package doesn't actually build libgcc. Instead, the version
listed below is built manually (for now), for the purpose of generating the
corresponding symbol tables for dependency resolution.
"""

VERSION = "10.2.0"

URLS = [
    "ftp://ftp.gnu.org/gnu/gcc/gcc-{version}/gcc-{version}.tar.xz",
    "http://mirror.kumi.systems/gnu/gcc/gcc-{version}/gcc-{version}.tar.xz",
]
