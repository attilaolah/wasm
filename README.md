# WebAssembly Playground

Scripts to compile libraries to [WebAssembly] using [Bazel].

To compile fir the local architecture, run:

```sh
$ bazel build ...
```

To cross-compile for [WebAssembly], run:

```sh
$ CC=emcc bazel build ...
```

[Bazel]: https://bazel.build
[Emscripten]: https://emscripten.org
[WebAssembly]: https://webassembly.org
