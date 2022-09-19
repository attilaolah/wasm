# WebAssembly Playground

<!-- DO NOT EDIT README.md!

This file was auto-generated based on the template file
`cmd/write_me/write_me.tpl`. Update the template file and then re-generate
the `README.md` file by running:

$ bazel run //cmd/write_me
-->

Scripts to compile libraries to [WebAssembly] using [Bazel].

To get (somewhat) reproducible results, run the builds in a Docker container.
To get a shell within the container, run build the image and run it:

```sh
$ docker build -t wasm docker
$ docker run -it -v "${PWD}:/build" wasm
```

Then build targets as usual. To compile WebAssembly using the Emscripten
toolchain, pass `--cpu=wasm32`. Pass `-c opt` for an optimised build.

## Libraries

| Build Label | Version |
|-------------|---------|
[`//lib/aec`](https://github.com/attilaolah/wasm/blob/main/lib/aec/BUILD.bazel) | 1.0.6 [🔗](https://gitlab.dkrz.de/k202009/libaec/-/archive/v1.0.6/libaec-v1.0.6.tar.bz2)
[`//lib/bison`](https://github.com/attilaolah/wasm/blob/main/lib/bison/BUILD.bazel) | 3.7.6 [🔗](https://ftp.gnu.org/gnu/bison/bison-3.7.6.tar.xz)
[`//lib/blas`](https://github.com/attilaolah/wasm/blob/main/lib/blas/BUILD.bazel) | 3.10.0 [🔗](http://www.netlib.org/blas/blas-3.10.0.tgz)
[`//lib/boost`](https://github.com/attilaolah/wasm/blob/main/lib/boost/BUILD.bazel) | 1.77.0 [🔗](https://boostorg.jfrog.io/ui/api/v1/download?repoKey=main&path=release/1.77.0/source/boost_1_77_0.tar.gz)
[`//lib/bz2`](https://github.com/attilaolah/wasm/blob/main/lib/bz2/BUILD.bazel) | 1.0.8 [🔗](https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz)
[`//lib/ceres`](https://github.com/attilaolah/wasm/blob/main/lib/ceres/BUILD.bazel) | 2.1.0 [🔗](https://github.com/ceres-solver/ceres-solver/archive/2.1.0.tar.gz)
[`//lib/cmark`](https://github.com/attilaolah/wasm/blob/main/lib/cmark/BUILD.bazel) | 0.30.2 [🔗](https://github.com/commonmark/cmark/archive/refs/tags/0.30.2.tar.gz)
[`//lib/cmarkgfm`](https://github.com/attilaolah/wasm/blob/main/lib/cmarkgfm/BUILD.bazel) | 0.29.0.gfm.3 [🔗](https://github.com/github/cmark-gfm/archive/refs/tags/0.29.0.gfm.3.tar.gz)
[`//lib/curl`](https://github.com/attilaolah/wasm/blob/main/lib/curl/BUILD.bazel) | 7.82.0 [🔗](https://curl.se/download/curl-7.82.0.tar.xz)
[`//lib/deflate`](https://github.com/attilaolah/wasm/blob/main/lib/deflate/BUILD.bazel) | 1.7 [🔗](https://github.com/ebiggers/libdeflate/archive/v1.7.tar.gz)
[`//lib/eigen`](https://github.com/attilaolah/wasm/blob/main/lib/eigen/BUILD.bazel) | 3.4.0 [🔗](https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.bz2)
[`//lib/exiv2`](https://github.com/attilaolah/wasm/blob/main/lib/exiv2/BUILD.bazel) | 0.27.5 [🔗](https://github.com/Exiv2/exiv2/releases/download/v0.27.5/exiv2-0.27.5-Source.tar.gz)
[`//lib/expat`](https://github.com/attilaolah/wasm/blob/main/lib/expat/BUILD.bazel) | 2.2.10 [🔗](https://github.com/libexpat/libexpat/releases/download/R_2_2_10/expat-2.2.10.tar.xz)
[`//lib/ffi`](https://github.com/attilaolah/wasm/blob/main/lib/ffi/BUILD.bazel) | 3.3 [🔗](https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz)
[`//lib/fftw`](https://github.com/attilaolah/wasm/blob/main/lib/fftw/BUILD.bazel) | 3.3.10 [🔗](http://www.fftw.org/fftw-3.3.10.tar.gz)
[`//lib/flex`](https://github.com/attilaolah/wasm/blob/main/lib/flex/BUILD.bazel) | 2.6.4 [🔗](https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz)
[`//lib/gcc`](https://github.com/attilaolah/wasm/blob/main/lib/gcc/BUILD.bazel) | 10.2.0 [🔗](https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.xz) [🔗](https://mirror.kumi.systems/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.xz)
[`//lib/gdal`](https://github.com/attilaolah/wasm/blob/main/lib/gdal/BUILD.bazel) | 3.4.2 [🔗](http://download.osgeo.org/gdal/3.4.2/gdal-3.4.2.tar.gz) [🔗](https://github.com/OSGeo/gdal/releases/download/v3.4.2/gdal-3.4.2.tar.gz)
[`//lib/geos`](https://github.com/attilaolah/wasm/blob/main/lib/geos/BUILD.bazel) | 3.10.2 [🔗](https://github.com/libgeos/geos/archive/3.10.2.tar.gz)
[`//lib/geotiff`](https://github.com/attilaolah/wasm/blob/main/lib/geotiff/BUILD.bazel) | 1.6.0 [🔗](https://github.com/OSGeo/libgeotiff/releases/download/1.6.0/libgeotiff-1.6.0.tar.gz)
[`//lib/gflags`](https://github.com/attilaolah/wasm/blob/main/lib/gflags/BUILD.bazel) | 2.2.2 [🔗](https://github.com/gflags/gflags/archive/v2.2.2.tar.gz)
[`//lib/gif`](https://github.com/attilaolah/wasm/blob/main/lib/gif/BUILD.bazel) | 5.2.1 [🔗](https://downloads.sourceforge.net/project/giflib/giflib-5.2.1.tar.gz)
[`//lib/glog`](https://github.com/attilaolah/wasm/blob/main/lib/glog/BUILD.bazel) | 0.4.0 [🔗](https://github.com/google/glog/archive/v0.4.0.tar.gz)
[`//lib/gmp`](https://github.com/attilaolah/wasm/blob/main/lib/gmp/BUILD.bazel) | 6.2.1 [🔗](https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz)
[`//lib/grass`](https://github.com/attilaolah/wasm/blob/main/lib/grass/BUILD.bazel) | 8.0.1 [🔗](https://grass.osgeo.org/grass80/source/grass-8.0.1.tar.gz)
[`//lib/hdf`](https://github.com/attilaolah/wasm/blob/main/lib/hdf/BUILD.bazel) | 4.2.15 [🔗](https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.15/src/hdf-4.2.15.tar.gz)
[`//lib/hdf5`](https://github.com/attilaolah/wasm/blob/main/lib/hdf5/BUILD.bazel) | 1.12.0 [🔗](https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-1.12.0/src/hdf5-1.12.0.tar.gz) [🔗](https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_1_12_0/source/hdf5-1.12.0.tar.gz)
[`//lib/iconv`](https://github.com/attilaolah/wasm/blob/main/lib/iconv/BUILD.bazel) | 1.16 [🔗](https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz)
[`//lib/imath`](https://github.com/attilaolah/wasm/blob/main/lib/imath/BUILD.bazel) | 3.1.5 [🔗](https://github.com/AcademySoftwareFoundation/imath/archive/refs/tags/v3.1.5.tar.gz)
[`//lib/jpegturbo`](https://github.com/attilaolah/wasm/blob/main/lib/jpegturbo/BUILD.bazel) | 2.1.0 [🔗](https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.1.0.tar.gz)
[`//lib/jq`](https://github.com/attilaolah/wasm/blob/main/lib/jq/BUILD.bazel) | 1.6 [🔗](https://github.com/stedolan/jq/releases/download/jq-1.6/jq-1.6.tar.gz)
[`//lib/lcms`](https://github.com/attilaolah/wasm/blob/main/lib/lcms/BUILD.bazel) | 2.12 [🔗](https://downloads.sourceforge.net/project/lcms/lcms/2.12/lcms2-2.12.tar.gz)
[`//lib/lz4`](https://github.com/attilaolah/wasm/blob/main/lib/lz4/BUILD.bazel) | 1.9.3 [🔗](https://github.com/lz4/lz4/archive/v1.9.3.tar.gz)
[`//lib/lzma`](https://github.com/attilaolah/wasm/blob/main/lib/lzma/BUILD.bazel) | 5.2.5 [🔗](https://tukaani.org/xz/xz-5.2.5.tar.xz)
[`//lib/lzo`](https://github.com/attilaolah/wasm/blob/main/lib/lzo/BUILD.bazel) | 2.10 [🔗](https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz)
[`//lib/m4`](https://github.com/attilaolah/wasm/blob/main/lib/m4/BUILD.bazel) | 1.4.19 [🔗](https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz)
[`//lib/mpdecimal`](https://github.com/attilaolah/wasm/blob/main/lib/mpdecimal/BUILD.bazel) | 2.5.1 [🔗](https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.5.1.tar.gz)
[`//lib/mpfr`](https://github.com/attilaolah/wasm/blob/main/lib/mpfr/BUILD.bazel) | 4.1.0 [🔗](https://www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.xz) [🔗](https://ftp.gnu.org/gnu/mpfr/mpfr-4.1.0.tar.xz)
[`//lib/musl`](https://github.com/attilaolah/wasm/blob/main/lib/musl/BUILD.bazel) | 1.2.2 [🔗](https://musl.libc.org/releases/musl-1.2.2.tar.gz)
[`//lib/ncurses`](https://github.com/attilaolah/wasm/blob/main/lib/ncurses/BUILD.bazel) | 6.2 [🔗](https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz)
[`//lib/oniguruma`](https://github.com/attilaolah/wasm/blob/main/lib/oniguruma/BUILD.bazel) | 6.9.6 [🔗](https://github.com/kkos/oniguruma/releases/download/v6.9.6/onig-6.9.6.tar.gz)
[`//lib/opencv`](https://github.com/attilaolah/wasm/blob/main/lib/opencv/BUILD.bazel) | 4.6.0 [🔗](https://github.com/opencv/opencv/archive/4.6.0.zip)
[`//lib/openexr`](https://github.com/attilaolah/wasm/blob/main/lib/openexr/BUILD.bazel) | 3.1.4 [🔗](https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/v3.1.4.tar.gz)
[`//lib/openjpeg`](https://github.com/attilaolah/wasm/blob/main/lib/openjpeg/BUILD.bazel) | 2.4.0 [🔗](https://github.com/uclouvain/openjpeg/archive/v2.4.0.tar.gz)
[`//lib/openssl`](https://github.com/attilaolah/wasm/blob/main/lib/openssl/BUILD.bazel) | 3.0.5 [🔗](https://www.openssl.org/source/openssl-3.0.5.tar.gz)
[`//lib/pano13`](https://github.com/attilaolah/wasm/blob/main/lib/pano13/BUILD.bazel) | 2.9.19 [🔗](https://download.sourceforge.net/panotools/libpano13-2.9.19.tar.gz)
[`//lib/png`](https://github.com/attilaolah/wasm/blob/main/lib/png/BUILD.bazel) | 1.6.37 [🔗](https://downloads.sourceforge.net/libpng/libpng-1.6.37.tar.gz)
[`//lib/proj`](https://github.com/attilaolah/wasm/blob/main/lib/proj/BUILD.bazel) | 8.0.1 [🔗](https://download.osgeo.org/proj/proj-8.0.1.tar.gz)
[`//lib/protobuf`](https://github.com/attilaolah/wasm/blob/main/lib/protobuf/BUILD.bazel) | 3.19.4 [🔗](https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-cpp-3.19.4.tar.gz)
[`//lib/python`](https://github.com/attilaolah/wasm/blob/main/lib/python/BUILD.bazel) | 3.10.7 [🔗](https://www.python.org/ftp/python/3.10.7/Python-3.10.7.tar.xz)
[`//lib/quirc`](https://github.com/attilaolah/wasm/blob/main/lib/quirc/BUILD.bazel) | 1.0.1 [🔗](https://github.com/evolation/libquirc/archive/refs/tags/1.0.1.tar.gz)
[`//lib/readline`](https://github.com/attilaolah/wasm/blob/main/lib/readline/BUILD.bazel) | 8.0 [🔗](https://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz)
[`//lib/sdl`](https://github.com/attilaolah/wasm/blob/main/lib/sdl/BUILD.bazel) | 2.24.0 [🔗](https://www.libsdl.org/release/SDL2-2.24.0.tar.gz)
[`//lib/sqlite`](https://github.com/attilaolah/wasm/blob/main/lib/sqlite/BUILD.bazel) | 3.35.5 [🔗](https://www.sqlite.org/2021/sqlite-autoconf-3350500.tar.gz)
[`//lib/suitesparse`](https://github.com/attilaolah/wasm/blob/main/lib/suitesparse/BUILD.bazel) | 5.9.0 [🔗](https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v5.9.0.tar.gz)
[`//lib/szip`](https://github.com/attilaolah/wasm/blob/main/lib/szip/BUILD.bazel) | 2.1.1 [🔗](https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz)
[`//lib/tcl`](https://github.com/attilaolah/wasm/blob/main/lib/tcl/BUILD.bazel) | 8.6.11 [🔗](https://downloads.sourceforge.net/tcl/tcl8.6.11-src.tar.gz)
[`//lib/tiff`](https://github.com/attilaolah/wasm/blob/main/lib/tiff/BUILD.bazel) | 4.2.0 [🔗](https://download.osgeo.org/libtiff/tiff-4.2.0.tar.gz)
[`//lib/tirpc`](https://github.com/attilaolah/wasm/blob/main/lib/tirpc/BUILD.bazel) | 1.3.1 [🔗](https://downloads.sourceforge.net/project/libtirpc/libtirpc/1.3.1/libtirpc-1.3.1.tar.bz2)
[`//lib/vigra`](https://github.com/attilaolah/wasm/blob/main/lib/vigra/BUILD.bazel) | 1.11.1 [🔗](https://github.com/ukoethe/vigra/releases/download/Version-1-11-1/vigra-1.11.1-src.tar.gz)
[`//lib/webp`](https://github.com/attilaolah/wasm/blob/main/lib/webp/BUILD.bazel) | 1.1.0 [🔗](https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.1.0.tar.gz)
[`//lib/xml`](https://github.com/attilaolah/wasm/blob/main/lib/xml/BUILD.bazel) | 2.9.10 [🔗](http://xmlsoft.org/sources/libxml2-2.9.10.tar.gz)
[`//lib/xslt`](https://github.com/attilaolah/wasm/blob/main/lib/xslt/BUILD.bazel) | 1.1.34 [🔗](http://xmlsoft.org/sources/libxslt-1.1.34.tar.gz)
[`//lib/z`](https://github.com/attilaolah/wasm/blob/main/lib/z/BUILD.bazel) | 1.2.11 [🔗](https://downloads.sourceforge.net/libpng/zlib-1.2.11.tar.gz)
[`//lib/zstd`](https://github.com/attilaolah/wasm/blob/main/lib/zstd/BUILD.bazel) | 1.5.0 [🔗](https://github.com/facebook/zstd/releases/download/v1.5.0/zstd-1.5.0.tar.gz)


## Tools

| Build Label | Version |
|-------------|---------|
[`//tools/emscripten`](https://github.com/attilaolah/wasm/blob/main/tools/emscripten/BUILD.bazel) | 3.1.8 [🔗](https://github.com/emscripten-core/emscripten/archive/refs/tags/3.1.8.tar.gz)
[`//tools/llvm`](https://github.com/attilaolah/wasm/blob/main/tools/llvm/BUILD.bazel) | 12.0.0 [🔗](https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz)


[Bazel]: https://bazel.build
[WebAssembly]: https://webassembly.org
