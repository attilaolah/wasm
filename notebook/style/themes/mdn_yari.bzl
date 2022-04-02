"""Repository rule for downloading the MDN Yari theme repo."""

load("//:http_archive.bzl", "http_archive")

VERSION = "462cdd758f911616f111402858b5a142e0606a67"  # main @ 2022-04-01T11:17:47Z

SHA256 = "bac279260a0e522c956f584a0d190f57ce110c6c6dd4d0a82f06c087f9317dfa"

def download():
    http_archive(
        name = "mdn_yari",
        version = VERSION,
        urls = ["https://github.com/mdn/yari/archive/{version}.zip"],
        sha256 = SHA256,
        strip_prefix = "yari-{version}",
        build_file = "//notebook/style:themes/mdn_yari.bazel",
    )
