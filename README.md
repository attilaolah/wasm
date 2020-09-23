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
- Pass `--config=wasm64` to target WebAssembly.

### Selecting the build type:
- The default build type is fastbuild.
- Pass `--compilation_mode=opt` (or `-c opt`) to produce an optimised build.

## Build status

| Library            | Version | `x86_64` | `x86_64 -c opt` | `wasm64` | `wasm64 -c opt` |
|--------------------|---------|:--------:|:---------------:|:--------:|:---------------:|
| `//lib/gif`        | 5.2.1   | ❌¹      | ✅              | ❌¹      | ✅              |
| `//lib/jpeg_turbo` | 2.0.4   | ✅       | ✅              | ✅       | ✅              |
| `//lib/lz4`        | 1.9.2   | ✅       | ✅              | ✅       | ✅              |
| `//lib/lzma`       | 5.2.4   | ✅       | ✅              | ✅       | ✅              |
| `//lib/z`          | 1.2.11  | ✅       | ✅              | ✅       | ✅              |
| `//lib/zstd`       | 1.4.4   | ✅       | ✅              | ✅       | ✅              |

Notes:

1. `libgif` actually builds in optimised mode even when building with `-c opt`.
   This is because the compiler flags don't get propagated correctly.

[Bazel]: https://bazel.build
[WebAssembly]: https://webassembly.org
