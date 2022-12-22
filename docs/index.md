---
autorun: true
---

# Web Notebooks

Web notebooks are simple, self-hosted Markdown documents, with code blocks that
are executed entirely in the browser -- no "backend" needed. In fact, this page
is such a notebook! Look at the source code (`Ctrl+U` in Chrome) to learn more.

The entire page is written in Markdown, with a single script tag and a
`<body>` on the first line.

The runtime supports a few types of code blocks out of the bock, like
[JavaScript](#code-blocks), [HTML](#html-blocks) and [CSS](#css-blocks).

## Code Blocks

Code blocks must be tagged with a language tag. Currently only JavaScript is
supported, but other languages may be added in the future. Here is an simple
example:

```js
new Date()
```

The entire block is passed to `eval?.(…)` as-is, and the return value is
JSON-formatted, unless it is `undefined`. As a special-case, if the return
value is a DOM `Node` instance, it is added directly to the output. The return
value of the previous block is accessible using the `_` variable:

```js
const [year, month, day] = [
  _.getFullYear(),
  _.getMonth() + 1,  // months are zero-based
  _.getDate(),
];
({year, month, day})
```

Errors are caught and will result in a `FAIL`ed code block. After a failure,
`_` will return to the caught exception.

```js
const {day} = _;
if (day % 2) {
  throw `error: ${day} is too odd`;
} else {
  throw `panic: ${day} is not odd enough`;
}
```

## HTML Blocks

HTML can be included just like any other code snipped, using the `html` tag.
The HTML is simply copied to the output, no questions asked.


```html
<img
  src="https://attilaolah.eu/avatar/192.jpg"
  class="avatar">
```

The `_` variable will refer to the last element, which is handy when accessing
it from subsequent JavaScript blocks:

```js
_.addEventListener("click", (evt) => {
  evt.target.classList.toggle("on");
})
```

The HTML block is most useful to declare custom outputs, for example a
`<canvas>` tag that subsequent JavaScript blocks will paint on. Or a simple
button to interact with the page.

## CSS Blocks

CSS code blocks are a bit special, in that they have no output, but instead
modify the stylesheet of the entire page. They can of course target any HTML
content added in other blocks too:

```css
img.avatar {
  --size: 64px;
  width: var(--size);
  height: var(--size);
  border-radius: calc(var(--size) / 2);
  border: none;
}
img.avatar.on {
  border: 2px solid purple;
}
```

The CSS block can be used to provide basic styling to HTML blocks in a less
cumbersome way. The resulting `_` variable will hold the generated
`CSSStyleSheet` instance.

## Front Matter

The Markdown front matter is used to configure the notebook itself. This page
has the following config in the front matter:

```yaml
autorun: true
```

The config is also available at runtime, on the `Notebook` object's `config`
property:

```js
notebook.config
```
