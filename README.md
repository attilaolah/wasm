# WebAssembly Playground

<!-- DO NOT EDIT README.md!

This file was auto-generated based on the template file
`cmd/write_me/write_me.tpl`. Update the template file and then re-generate
the `README.md` file by running:

$ bazel run //cmd/write_me -- -root="${PWD}" > README.md
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
[`//lib/ceres`](https://github.com/attilaolah/wasm/blob/main/lib/ceres/BUILD.bazel) | 1.14.0
[`//lib/curl`](https://github.com/attilaolah/wasm/blob/main/lib/curl/BUILD.bazel) | 7.75.0
[`//lib/deflate`](https://github.com/attilaolah/wasm/blob/main/lib/deflate/BUILD.bazel) | 1.7
[`//lib/eigen`](https://github.com/attilaolah/wasm/blob/main/lib/eigen/BUILD.bazel) | 3.3.8-rc1
[`//lib/ffi`](https://github.com/attilaolah/wasm/blob/main/lib/ffi/BUILD.bazel) | 3.3
[`//lib/fftw`](https://github.com/attilaolah/wasm/blob/main/lib/fftw/BUILD.bazel) | 3.3.8
[`//lib/gflags`](https://github.com/attilaolah/wasm/blob/main/lib/gflags/BUILD.bazel) | 2.2.2
[`//lib/gif`](https://github.com/attilaolah/wasm/blob/main/lib/gif/BUILD.bazel) | 5.2.1
[`//lib/glog`](https://github.com/attilaolah/wasm/blob/main/lib/glog/BUILD.bazel) | 0.4.0
[`//lib/gmp`](https://github.com/attilaolah/wasm/blob/main/lib/gmp/BUILD.bazel) | 6.2.1
[`//lib/hdf5`](https://github.com/attilaolah/wasm/blob/main/lib/hdf5/BUILD.bazel) | 1.12.0
[`//lib/jpeg_turbo`](https://github.com/attilaolah/wasm/blob/main/lib/jpeg_turbo/BUILD.bazel) | 2.0.90
[`//lib/lz4`](https://github.com/attilaolah/wasm/blob/main/lib/lz4/BUILD.bazel) | 1.9.3
[`//lib/lzma`](https://github.com/attilaolah/wasm/blob/main/lib/lzma/BUILD.bazel) | 5.2.5
[`//lib/mpfr`](https://github.com/attilaolah/wasm/blob/main/lib/mpfr/BUILD.bazel) | 4.1.0
[`//lib/open_ssl`](https://github.com/attilaolah/wasm/blob/main/lib/open_ssl/BUILD.bazel) | 1.1.1i
[`//lib/pano13`](https://github.com/attilaolah/wasm/blob/main/lib/pano13/BUILD.bazel) | 2.9.19
[`//lib/png`](https://github.com/attilaolah/wasm/blob/main/lib/png/BUILD.bazel) | 1.6.37
[`//lib/proj`](https://github.com/attilaolah/wasm/blob/main/lib/proj/BUILD.bazel) | 7.2.0
[`//lib/python`](https://github.com/attilaolah/wasm/blob/main/lib/python/BUILD.bazel) | 3.9.1
[`//lib/readline`](https://github.com/attilaolah/wasm/blob/main/lib/readline/BUILD.bazel) | 8.0
[`//lib/sqlite`](https://github.com/attilaolah/wasm/blob/main/lib/sqlite/BUILD.bazel) | 3.34.1
[`//lib/suite_sparse`](https://github.com/attilaolah/wasm/blob/main/lib/suite_sparse/BUILD.bazel) | 5.8.1
[`//lib/tiff`](https://github.com/attilaolah/wasm/blob/main/lib/tiff/BUILD.bazel) | 4.2.0
[`//lib/vigra`](https://github.com/attilaolah/wasm/blob/main/lib/vigra/BUILD.bazel) | 1.11.1
[`//lib/webp`](https://github.com/attilaolah/wasm/blob/main/lib/webp/BUILD.bazel) | 1.1.0
[`//lib/z`](https://github.com/attilaolah/wasm/blob/main/lib/z/BUILD.bazel) | 1.2.11
[`//lib/zstd`](https://github.com/attilaolah/wasm/blob/main/lib/zstd/BUILD.bazel) | 1.4.8


## Tools

| Build Label | Version |
|-------------|---------|
[`//tools/emscripten`](https://github.com/attilaolah/wasm/blob/main/tools/emscripten/BUILD.bazel) | 2.0.13
[`//tools/llvm`](https://github.com/attilaolah/wasm/blob/main/tools/llvm/BUILD.bazel) | 11.0.1


[Bazel]: https://bazel.build
[WebAssembly]: https://webassembly.org
