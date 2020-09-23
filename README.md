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

| Library   | Version | `x86_64` | `x86_64 -c opt` | `wasm64` | `wasm64 -c opt` |
|-----------|---------|:--------:|:---------------:|:--------:|:---------------:|
| `//lib/z` | 1.2.11  | ✅       | ✅              | ✅       | ✅              |

[Bazel]: https://bazel.build
[WebAssembly]: https://webassembly.org
