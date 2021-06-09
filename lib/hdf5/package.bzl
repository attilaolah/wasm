"""Workspace rule for downloading package dependencies."""

load("//:http_archive.bzl", "http_archive")

VERSION = "1.12.0"

URLS = [
    "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-{versionmm}/hdf5-{version}/src/hdf5-{version}.tar.gz",
    "https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_{version_}/source/hdf5-{version}.tar.gz",
]

SHA256 = "a62dcb276658cb78e6795dd29bf926ed7a9bc4edf6e77025cd2c689a8f97c17a"

def download_hdf5():
    http_archive(
        name = "lib_hdf5",
        version = VERSION,
        urls = URLS,
        sha256 = SHA256,
        strip_prefix = "hdf5-{version}",
        patch_cmds = [
            # Remove Emscripten-specific compile options.
            # Let Bazel specify the compile time options for everything.
            # Source: https://github.com/HDFGroup/hdf5/commit/6ee2c3b0099cd9506579d192ff8785a64f81a607
            "sed -i src/CMakeLists.txt -e '/PLATFORM_ID:Emscripten/d'",
            # Fix H5Tinit.c source file generation.
            # Source: https://github.com/HDFGroup/hdf5/pull/357/commits/fd87bb1b244169004ec3a16e03059d64a87e7270
            "sed -i src/CMakeLists.txt -e 's:{}:{}:g'".format(
                "ARGS ${HDF5_GENERATED_SOURCE_DIR}/H5Tinit.c",
                "ARGS > ${HDF5_GENERATED_SOURCE_DIR}/H5Tinit.c",
            ),
            # Fix H5lib_settings.c source file generation:
            # Source: https://github.com/HDFGroup/hdf5/pull/357/commits/fd87bb1b244169004ec3a16e03059d64a87e7270
            "sed -i src/CMakeLists.txt -e 's:{}:{}:g'".format(
                "ARGS ${HDF5_BINARY_DIR}/H5lib_settings.c",
                "ARGS > ${HDF5_BINARY_DIR}/H5lib_settings.c",
            ),
            # Remove auto-generated headers, so they can be re-generated:
            "rm {}".format(" ".join([
                header
                for header in [
                    # Auto-generated headers, keep sorted:
                    "src/H5Edefin.h",
                    "src/H5Einit.h",
                    "src/H5Epubgen.h",
                    "src/H5Eterm.h",
                ]
            ])),
        ],
    )
