# WebAssembly Playground

<!-- DO NOT EDIT README.md!

This file was auto-generated based on the template file
`cmd/write_me/write_me.tpl`. Update the template file and then re-generate
the `README.md` file by running:

$ bazel run //cmd/write_me
-->

Scripts to compile libraries to [WebAssembly] using [Bazel].

To get fully reproducible results, run the build inside a NixOS container:

```sh
$ docker run -it -v "$PWD:/build" nixpkgs/nix:nixos-23.11
```

Then, inside the container, run `nix-shell` to create the build environment:

```sh
$ cd /build
$ NIX_PATH=nixpkgs=channel:nixos-unstable nix-shell
```

Once that completes, you can build as usual:

```sh
$ bazelisk build //lib/ffmpeg:wasm_bindings --config=emscripten -c opt
```

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
