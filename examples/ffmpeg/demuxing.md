---
autorun: true
---

# FFMpeg: Demuxing

This example shows how to open a video file and print details about the input
streams, similar to running `ffprobe`. We will use [this video of a kookaburra]
as input. The container format requires building FFmpeg with
`--enable-demuxers=mov`.

[this video of a kookaburra]: https://www.pexels.com/video/a-kookaburra-bird-in-captive-2461326/

```html
<video width=640 height=360 controls></video>
```

```js
const res = await fetch("/examples/data/kookaburra.360p.mov.h264.mp4");
const blob = await res.blob();
self.data = new Uint8Array(await blob.arrayBuffer());

_[0].src = URL.createObjectURL(blob);
```

The tricky part here will be providing the correct `read_packet` function to
FFmpeg. For this simple example, we'll pass a function that ignores the
"opaque" pointer entirely, and always reads from the `data` object defined
above.

A more flexible (and probably faster) approach would be to use the [Streams
API] with an intermedite buffer, but that is left as an exercise for the
reader.

[Streams API]: https://developer.mozilla.org/en-US/docs/Web/API/Streams_API


```js
const module = await import(`${location.href}/../ffmpeg.js`);
self.ffmpeg = await new module.default();
```

The first thing to do is to allocate an `AVFormatContext`. This will be used by
most subsequent operations.

```js
self.fmtCtx = ffmpeg.ccall("avformat_alloc_context", "number");
if (!fmtCtx) {
  throw new Error("cannot allocate memory");
}
```

Then we need an `AVIOContext` to pass in our callback function.

```js
const bufSize = 4096;
const buf = ffmpeg.ccall("av_malloc", "number", ["number"], [bufSize]);
if (!buf) {
  throw new Error("cannot allocate memory");
}

const ioCtx = ffmpeg.ccall("avio_alloc_context", "number", [
  "number", // *buffer
  "number", // buffer_size
  "number", // write_flag
  "number", // *opaque
  "number", // *read_packet
  "number", // *write_packet
  "number", // *seek
], [
  buf,
  bufSize,
  0,
  null,
  ffmpeg.addFunction((opaque, buf, size) => {
    size = size > data.byteLength ? data.byteLength : size;
    if (!size) { return -541478725; } // AVERROR_EOF
    ffmpeg.writeArrayToMemory(data.slice(0, size), buf);
    data = data.slice(size);
    return size;
  }, "iiii"),
  null,
  null,
]);
if (!ioCtx) {
  throw new Error("cannot allocate memory");
}

self.usize = ffmpeg.getNativeTypeSize("*");
self.HEAP = ffmpeg[`HEAPU${usize*8}`]

HEAP[fmtCtx/usize + 4] = ioCtx;
```

Now that we have the IO context, we should be able to start reading data. This
will fail unless the `mov` demuxer was enabled at compile time.

```js
const ps = ffmpeg.ccall("malloc", "number", ["number"], [usize])
ffmpeg[`HEAPU${usize*8}`][ps/usize] = fmtCtx;

const err = ffmpeg.ccall("avformat_open_input", "number", [
  "number", // **ps
  "number", // *url
  "number", // *fmt
  "number", // **options
], [ps, null, null, null]);
if (err < 0) {
  throw new Error(`failed to open input: error code ${err}`);
}
```

If that went well, we can try to detect the stream info.

```js
const err = ffmpeg.ccall("avformat_find_stream_info", "number", [
  "number", // *ic
  "number", // **options
], [fmtCtx, null]);
if (err < 0) {
  throw new Error(`failed to find stream information: error code ${err}`);
}
```

Now we should have the number of streams, the input format and the duration,
among others:

```js
const iFormat = HEAP[fmtCtx/usize + 1];  // fmt_ctx->iformat

return {
  num_streams: HEAP[fmtCtx/usize + 6],  // fmt_ctx->nb_streams
  input_format: ffmpeg.UTF8ToString(HEAP[iFormat/usize]),  // fmt_ctx->iformat->name
  duration_secs: Number(ffmpeg.HEAP64[fmtCtx/8 + (usize/4)*5 + 1]) / 1000000,
};
```
