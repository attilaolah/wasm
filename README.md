# WebAssembly Playground

Scripts to compile libraries to [WebAssembly] using [Bazel].

To get (somewhat) reproducible results, run the builds in a Docker container.
To get a shell within the container, run build the image and run it:

```sh
$ docker build -t wasm docker
$ docker run -it -v "${PWD}:/build" wasm
```

Then build as normally.


Host (x86\_64) fastbuild:

```sh
$ bazel build //lib/...
```

Host (x86\_64) optimised build:

```sh
$ bazel build -c opt //lib/...
```

The same but cross-compiled for WebAssembly:

```sh
$ bazel build --config=wasm64 //lib/...
$ bazel build --config=wasm64 -c opt //lib/...
```


[Bazel]: https://bazel.build
[WebAssembly]: https://webassembly.org
