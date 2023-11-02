---
autorun: true
---

# FFMpeg: List Known Pixel Formats

This example shows how to list available pixel formats. The output should be
identical to the output of running `ffprobe -pix_fmts`. The HTML block below
creates a container for the output text, then the JS block below it fills the
container. Make sure to execute the HTML block before running the JavaScript
below.

```html
<pre id="out"></pre>
```

To populate the div, we iterate through each pixel format using the
`av_pix_fmt_desc_next` method below.

```js
const module = await import(`${location.href}/../ffmpeg.js`);
self.ffmpeg = await new module.default();

self.descriptors = [];

let desc = null;
while (desc = ffmpeg.ccall("av_pix_fmt_desc_next", "number", ["number"], [desc])) {
  descriptors.push(desc);
}

// How many are there?
return descriptors.length;
```

The contents of the `descriptors` array are numbers, representing pointers to C
[`AVPixFmtDescriptor`] structs. These could be parsed using a package like
[ref-struct], but here we will just parse the values manually.

[`AVPixFmtDescriptor`]: https://ffmpeg.org/doxygen/4.0/structAVPixFmtDescriptor.html
[ref-struct]: https://www.npmjs.com/package/ref-struct

```js
class PixelFormat {
  #id;
  #ptr;

  constructor(ptr) {
    this.#id = ffmpeg.ccall("av_pix_fmt_desc_get_id", "number", ["number"], [ptr]);
    this.#ptr = ptr;
  }

  // Format as a single line of the output text.
  toString() {
    return [
      this.#flags(),
      alignLeft(this.#name(), 22),
      this.#nb_components(),
      alignRight(this.#bits_per_pixel(), 14),
      "    ",
      this.#bit_depths(),
    ].join(" ");
  }

  #name() {
    return ffmpeg.UTF8ToString(HEAP[this.#ptr/usize]);
  }

  #nb_components() {
    return ffmpeg.HEAPU8[this.#ptr+usize];
  }

  #bits_per_pixel() {
    return ffmpeg.ccall(
      "av_get_bits_per_pixel", "number", ["number"], [this.#ptr]
    ) || "N/A";
  }

  #flags() {
    const val = ffmpeg.HEAPU64[this.#ptr/8+1];
    return [
      ffmpeg.ccall("sws_isSupportedInput", "number", ["number"], [this.#id]) ? "I" : ".",
      ffmpeg.ccall("sws_isSupportedOutput", "number", ["number"], [this.#id]) ? "O" : ".",
      (val & (1n << 3n)) ? "H" : ".",
      (val & (1n << 1n)) ? "P" : ".",
      (val & (1n << 2n)) ? "B" : ".",
    ].join("");
  }

  #bit_depths() {
    return Array
      .from(Array(this.#nb_components()).keys())
      .map((i) => HEAP[this.#ptr/usize + 2 + 8/usize + 5*i + 4])
      .join("-");
  }
}
self.PixelFormat = PixelFormat;

// Length of a pointer (in bytes):
const usize = ffmpeg.getNativeTypeSize("*");

// Heap as a typed array:
const HEAP = ffmpeg[`HEAPU${usize*8}`];

// Align text:
function alignLeft(text, width) {
  return (text + Array(width+1).join(" ")).slice(0, width);
}

// Right-align text:
function alignRight(text, width) {
  return (Array(width+1).join(" ") + text)
    .split("")
    .reverse()
    .slice(0, width)
    .reverse()
    .join("");
}
```

Finally we populate the output container:

```js
document
  .getElementById("out")
  .append(
    `Pixel formats:
I.... = Supported Input  format for conversion
.O... = Supported Output format for conversion
..H.. = Hardware accelerated format
...P. = Paletted format
....B = Bitstream format
FLAGS NAME            NB_COMPONENTS BITS_PER_PIXEL BIT_DEPTHS
-----
` + descriptors
      .map(desc => new PixelFormat(desc))
      .join("\n")
  );
```
