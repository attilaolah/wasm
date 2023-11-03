---
autorun: true
---

# FFmpeg Demo

This demo shows example usage of the [FFmpeg library] from the browser. The JS
file is compiled as an ES6 module, so we need to load it as such. The module is
available as the default export, and instantiating it gives a promise that we
need to await:

[FFmpeg library]: https://www.ffmpeg.org

```js
const module = await import(`${location.href}/ffmpeg.js`);
self.ffmpeg = await new module.default();
```

When using from a module, we would normally import it using something like
`import * as FFmpeg from "ffmpeg.js"`, but since code blocks in this notebook
are not executed in a module context, we need to use [dynamic imports].

[dynamic imports]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import

To quickly check that it worked, we can simply call the C function exporting
the version string:

```js
return ffmpeg.ccall("av_version_info", "string");
```

Note that there are more convenient ways to call C functions. These are
described the Emscripten documentation under [Interacting with code]. A simple
improvement would be to use `cwrap` instead of `ccall`:

[Interacting with code]: https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html

```js
const avVersionInfo = ffmpeg.cwrap("av_version_info", "string", []);
return avVersionInfo();
```

When working with pointers or structs, it is usually easier to write a wrapper
in C or C++ and export it using Emscripten bindings. Alternatively, we could
write a Rust wrapper using wasm-bindgen.

However, in these examples we will use vanilla JS to interact with the library
without any JavaScript prelude (i.e. no `--pre-js` flag). This requires
exporting the underlying runtime functions from the Emscripten module.

The following pages show more complex examples of using the library:

- [List known pixel formats](/examples/ffmpeg/pix-fmts)
- [Demux a MOV/H264 video file](/examples/ffmpeg/demuxing)

For more features, a custom version of the library could be compiled. To list
available features, we could check the configuration flags used when compiling
the library:

```js
return ffmpeg.ccall("avutil_configuration", "string")
  .replace(/\s--/g, '#--')
  .split('#');
```

These can be modified by changing the [`BUILD.bazel`] file under the
`//lib/ffmpeg` package.

[`BUILD.bazel`]: https://github.com/attilaolah/wasm/blob/main/lib/ffmpeg/BUILD.bazel
