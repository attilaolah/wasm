---
autorun: true
---

# Web Notebooks

Web notebooks are simple, self-hosted Markdown documents, with code blocks that
are executed entirely in the browser -- no "backend" needed. In fact, this page
is such a notebook! Look at the source code to learn more.

The entire page is written in Markdown, with a single script tag and a
`<body>` on the first line.

The runtime supports several types of code blocks out of the bock, like
[JavaScript](#code-blocks), [HTML](#html-blocks) and [CSS](#css-blocks). See
[the full list here](/code-blocks).

## Code Blocks

Code blocks must be tagged with a language tag. Currently only JavaScript is
supported, but other languages may be added in the future. Here is an simple
example:

```js
const now = new Date();
now; // return value
```

The entire block is executed with an indirect `eval(…)`, and the last
expression acts as a _return value_. This returned value is then
JSON-formatted, unless it is `undefined`. As a special-case, if the return
value is a DOM `Node` instance, it is added directly to the output.

The return value of the previous block is accessible using the `_` variable:

```js
// Anything we define here is scoped to this block.
// The "_" value holds the result of the previous block.
const [year, month, day] = [
  _.getFullYear(),
  _.getMonth() + 1,  // months are zero-based
  _.getDate(),
];

// Explicitly set the "today" variable:
self.today = ({year, month, day});
```

The `self` object points to the global `window` singleton, and it can be used
to pass around values between code blocks. Any property we set on `self` will
be accessible as a global variable in other blocks.

Anything thrown is caught and will result in a failed code block. After a
failure, `_` will hold the value that was thrown.

```js
// The variable "today" comes from the previous block.
const {day} = today;

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
<button class="lvl">LVL: 0</button>
```

The `_` variable will refer to the last element, which is handy when accessing
it from subsequent JavaScript blocks:

```js
let level = 0;
_.addEventListener("click", (evt) => {
  evt.currentTarget.innerText = `LVL: {++times}`;
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
button.lvl {
  --size: 48px;
  border-style: none;
  border-radius: calc(var(--size) / 2);
  background-color: rgb(var(--magenta));
  line-height: calc(var(--size) / 2);
  height: var(--size);
}
```

The CSS block can be used to provide basic styling to HTML blocks in a less
cumbersome way. The resulting `_` variable will hold the generated
`CSSStyleSheet` instance.

## Front Matter

The Markdown front matter is used to configure the notebook itself. This page
only configures `autorun: true`. The full list of configurable options is
[available here](/config).
