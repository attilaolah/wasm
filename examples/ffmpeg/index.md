---
autorun: true
---

# FFmpeg Demo

This demo shows example usage of the [FFmpeg library] from the browser. The
compilation script is in the corresponding `BUILD.bazel` file under
`//lib/ffmpeg`.

[FFmpeg library]: https://www.ffmpeg.org

The JS file is compiled as an ES6 module, so we need to load it as such. We
would normally import it as a module using something like `import * as FFmpeg
from "ffmpeg.js"`, but since code blocks in this notebook are not executed
in a module context, we need to use [dynamic imports].

[dynamic imports]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import

The module is available as the default export, and instantiating it gives a
promise that we need to await:

```js
const module = await import(`${location.href}/ffmpeg.js`);
self.ffmpeg = await new module.default();
```

## Check the library version

Let's do a quick check by verifying the FFmpeg version.

```js
return ffmpeg.ccall("av_version_info", "string");
```

Note that there are more convenient ways to call C functions. In this case, it
would have been simpler to wrap the function using `cwrap`, then call it. When
working with pointers or structs, it is usually easier to write a wrapper, e.g.
one of the following:

- A C or C++ wrapper exported using Emscripten bindings.
- A Rust wrapper exported using wasm-bindgen.

However, here we will use vanilla JS to interact with the library without any
JavaScript prelude (i.e. no `--pre-js` flag). This requires exporting the
underlying runtime functions from the Emscripten module.

## List known pixel formats

To show a slightly more complex example, let's list all known pixel formats.
The result should be similar to running `ffprobe -pix_fmts`.

```js
// Length of a pointer (in bytes):
const plen = ffmpeg.getNativeTypeSize("*");

// Heap as a typed array:
const HEAP = ffmpeg[`HEAPU${plen*8}`];

class PixelFormat {
  #id;
  #desc;
  constructor(desc) {
    this.#desc = desc;
    this.#id = ffmpeg.ccall("av_pix_fmt_desc_get_id", "number", ["number"], [desc]);
  }

  name() {
    return ffmpeg.UTF8ToString(HEAP[this.#desc/plen]);
  }

  nb_components() {
    return ffmpeg.HEAPU8[this.#desc+plen];
  }

  bits_per_pixel() {
    return ffmpeg.ccall(
      "av_get_bits_per_pixel", "number", ["number"], [this.#desc]
    ) || "N/A";
  }

  flags() {
    const val = ffmpeg.HEAPU64[this.#desc/8+1];
    return [
      ffmpeg.ccall("sws_isSupportedInput", "number", ["number"], [this.#id]) ? "I" : ".",
      ffmpeg.ccall("sws_isSupportedOutput", "number", ["number"], [this.#id]) ? "O" : ".",
      (val & (1n << 3n)) ? "H" : ".",
      (val & (1n << 1n)) ? "P" : ".",
      (val & (1n << 2n)) ? "B" : ".",
    ].join("");
  }

  bit_depths() {
    return Array
      .from(Array(this.nb_components()).keys())
      .map((i) => HEAP[this.#desc/plen + 2 + 8/plen + 5*i + 4])
      .join("-");
  }
}

let desc = null;
const descriptors = [];
while (desc = ffmpeg.ccall("av_pix_fmt_desc_next", "number", ["number"], [desc])) {
  descriptors.push(desc);
}

function align(text, width) {
  return (text + Array(width+1).join(" ")).slice(0, width);
}

function alignr(text, width) {
  return (Array(width+1).join(" ") + text)
    .split("")
    .reverse()
    .slice(0, width)
    .reverse()
    .join("");
}

document
  .getElementById("pix-fmts")
  .append(
    descriptors
      .map((desc) => new PixelFormat(desc))
      .map((fmt) => [
        fmt.flags(),
        align(fmt.name(), 22),
        fmt.nb_components(),
        alignr(fmt.bits_per_pixel(), 14),
        "    ",
        fmt.bit_depths(),
      ].join(" "))
      .join("\n")
  );
```

Here is the output of the above code:

<pre id="pix-fmts">
Pixel formats:
I.... = Supported Input  format for conversion
.O... = Supported Output format for conversion
..H.. = Hardware accelerated format
...P. = Paletted format
....B = Bitstream format
FLAGS NAME            NB_COMPONENTS BITS_PER_PIXEL BIT_DEPTHS
-----
</pre>
