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

Let's check that it worked by verifying the FFmpeg version:

```js
return ffmpeg.av_version_info();
```

