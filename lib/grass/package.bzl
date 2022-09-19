"""Workspace rule for downloading package dependencies."""

load("//lib:defs.bzl", "major_minor", "static_lib")
load("//lib:http_archive.bzl", "http_archive")

NAME = "grass"
VERSION = "8.0.1"

URL = "https://github.com/OSGeo/{name}/archive/refs/tags/{version}.tar.gz"

SHA256 = "e925bf8c44e1809459974457f2ab3c61dd5a24c0655ed026de665d1494f68a96"

STATIC_LIBS = [
    static_lib("{}_{}.{}".format(NAME, lib, major_minor(VERSION)))
    for lib in [
        # keep sorted
        "arraystats",
        "bitmap",
        "btree",
        "btree2",
        "calc",
        "ccmath",
        "cdhc",
        "cluster",
        "datetime",
        "dbmibase",
        "dbmiclient",
        "dbmidriver",
        "dbstubs",
        "dgl",
        "dig2",
        "display",
        "driver",
        "dspf",
        "g3d",
        "gis",
        "gmath",
        "gpde",
        "gproj",
        "htmldriver",
        "imagery",
        "interpdata",
        "interpfl",
        "iortho",
        "iostream",
        "lidar",
        "linkm",
        "lrs",
        "manage",
        "neta",
        "pngdriver",
        "psdriver",
        "qtree",
        "raster",
        "rli",
        "rowio",
        "rtree",
        "segment",
        "shape",
        "sim",
        "sqlp",
        "stats",
        "symb",
        "temporal",
        "vector",
        "vedit",
    ]
]

def download():
    http_archive(
        name = NAME,
        version = VERSION,
        urls = [URL],
        sha256 = SHA256,
        strip_prefix = "{name}-{version}",
        patches = ["//lib/grass:grass.patch"],
    )
