# WebAssembly Playground

Scripts to compile libraries to [WebAssembly] using [Bazel].

To get (somewhat) reproducible results, run the builds in a Docker container:

```sh
$ docker build -t wasm .
$ docker run --rm -v "${PWD}:/build" wasm
```

[Bazel]: https://bazel.build
[WebAssembly]: https://webassembly.org
