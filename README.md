# WebAssembly Playground

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
`//lib/ceres` | 1.14.0
`//lib/curl` | 7.75.0
`//lib/deflate` | 1.7
`//lib/eigen` | 3.3.8-rc1
`//lib/ffi` | 3.3
`//lib/fftw` | 3.3.8
`//lib/gflags` | 2.2.2
`//lib/gif` | 5.2.1
`//lib/glog` | 0.4.0
`//lib/gmp` | 6.2.1
`//lib/hdf5` | 1.12.0
`//lib/jpeg_turbo` | 2.0.90
`//lib/lz4` | 1.9.3
`//lib/lzma` | 5.2.5
`//lib/mpfr` | 4.1.0
`//lib/open_ssl` | 1.1.1i
`//lib/pano13` | 2.9.19
`//lib/png` | 1.6.37
`//lib/proj` | 7.2.0
`//lib/python` | 3.9.1
`//lib/readline` | 8.0
`//lib/sqlite` | 3.34.1
`//lib/suite_sparse` | 5.8.1
`//lib/tiff` | 4.2.0
`//lib/vigra` | 1.11.1
`//lib/webp` | 1.1.0
`//lib/z` | 1.2.11
`//lib/zstd` | 1.4.8


## Tools

| Build Label | Version |
|-------------|---------|
`//tools/emscripten` | 2.0.13
`//tools/llvm` | 11.0.1


[Bazel]: https://bazel.build
[WebAssembly]: https://webassembly.org
