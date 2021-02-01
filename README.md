# WebAssembly Playground

Scripts to compile libraries to [WebAssembly] using [Bazel].

To get (somewhat) reproducible results, run the builds in a Docker container.
To get a shell within the container, run build the image and run it:

```sh
$ docker build -t wasm docker
$ docker run -it -v "${PWD}:/build" wasm
```

Then build targets as usual.

### Selecting the target architecture:

- The default target is the host architecture.
- Pass `--config=wasm32` to target WebAssembly.

### Selecting the build type:
- The default build type is fastbuild.
- Pass `--compilation_mode=opt` (or `-c opt`) to produce an optimised build.

## Build status

| Library               | Version   | `x86_64` | `wasm32` |
|-----------------------|-----------|:--------:|:--------:|
| `//lib/ceres`         | 1.14.0    | ✅       | ❌       |
| `//lib/eigen`         | 3.3.8-rc1 | ✅       | ✅       |
| `//lib/fftw`          | 3.3.8     | ✅       | ✅       |
| `//lib/gflags`        | 2.2.2     | ✅       | ✅       |
| `//lib/gif`           | 5.2.1     | ✅¹      | ✅¹      |
| `//lib/glog`          | 0.4.0     | ✅       | ✅       |
| `//lib/gmp`           | 6.2.0     | ✅       |          |
| `//lib/mpfr`          | 4.1.0     | ✅       |          |
| `//lib/hdf5`          | 1.12.0    | ✅       | ❌       |
| `//lib/jpeg_turbo`    | 2.0.4     | ✅       | ✅       |
| `//lib/lz4`           | 1.9.2     | ✅       | ✅       |
| `//lib/lzma`          | 5.2.4     | ✅       | ✅       |
| `//lib/pano13`        | 2.9.19    | ✅       | ❌       |
| `//lib/png`           | 1.6.37    | ✅       | ✅       |
| `//lib/readline`      | 8.0       | ✅       | ❌       |
| `//lib/suite_sparse`² | 5.8.1     |          |          |
| `//lib/tiff`          | 4.1.0     | ✅       | ✅       |
| `//lib/vigra`         | 1.11.1    | ✅       | ❌       |
| `//lib/webp`          | 1.1.0     | ✅       | ✅       |
| `//lib/z`             | 1.2.11    | ✅       | ✅       |
| `//lib/zstd`          | 1.4.4     | ✅       | ✅       |

Notes:

1. `libgif` actually builds in optimised mode even when building without `-c opt`.
   This is because the compiler flags don't get propagated correctly.
2. There are many components under `//lib/suite_sparse`, but not all have been
   imported, e.g. the ones than require CUDA are currently missing.

[Bazel]: https://bazel.build
[WebAssembly]: https://webassembly.org
