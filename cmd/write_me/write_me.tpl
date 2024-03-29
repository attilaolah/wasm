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
$ docker run -it -v "${{`{PWD}`}}:/build" wasm
```

Then build targets as usual. To compile WebAssembly using the Emscripten
toolchain, pass `--cpu=wasm32`. Pass `-c opt` for an optimised build.

## Libraries

| Build Label | Version |
|-------------|---------|
{{.Libraries}}

## Tools

| Build Label | Version |
|-------------|---------|
{{.Tools}}
## Nix Shell

To get a Clang toolchain in a Nix environment, run `nix-shell`, it will pick up
the `shell.nix` file in the repo. This will set `$CC` to `clang`, along with
any necessary standard library paths.

[Bazel]: https://bazel.build
[WebAssembly]: https://webassembly.org
