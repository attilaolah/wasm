---
autorun: true
---

# Code Blocks

The built-in runtime supports the following languages:

- [JavaScript](#javascript)
- [HTML](#html)
- [CSS](#css)
- [JSON](#json)
- [YAML](#yaml)

Additional language support may be added by loading extensions.

## JavaScript

Tags: `javascript`, `js`. A simple example:

```js
self.assert = (test, message) => {
  if (!test) throw `assertion failed: ${message}`;
};
```

JavaScript code blocks are executed by the browser's JS engine. Each block is
wrapped in an `async` function to allow the use of the `await` keyword. This
block will be in _pending_ state for five seconds before it completes, blocking
the execution of any subsequent JavaScript blocks.

```js
const delay = 5000;  // five seconds
await new Promise(resolve => setTimeout(resolve, delay));
```

The fact that each block is its own function means that we can `return` early
from a function, but it also means we need an explicit `return` to provide a
return value for our code block. If no value is `return`ed, the return value is
`undefined`.

```js
return new Date();
```

The returned value of the previous block is accessible as `_`:

```js
assert(
  Object(_) instanceof Date,
  `want: ${Date.name}, got: ${_?.constructor.name}`,
);
```

Returned `Node` objects are directly injected to the DOM:

```js
const em = document.createElement("em");
em.innerText = navigator.userAgent;

const div = document.createElement("div");
div.append("User-Agent: ", em);

return div;
```

```js
assert(
  Object(_) instanceof Node,
  `want: ${Node.name}, got: ${_?.constructor.name}`,
);
```

Any errors are caught and displayed as a failed block. Syntax errors are caught
immediately, while runtime errors will only be caught when the block is
executed.

```js
assert(false, "false !== true");
```

This block below will fail immediately, even if the previous block is still
pending.

```js
KABOOM!!!
```

## HTML

Tag: `html`. A simple example:

```html
<strong class="test-html">
  Nothing <em>fancy</em> to see here…
</strong>
```

The returned value is the injected node.

```js
assert(
  _ instanceof HTMLElement,
  `want: ${HTMLElement.name}, got: ${_?.constructor.name}`,
);
```

## CSS

Tag: `css`. A simple example:

```css
strong.test-html {
  font-weight: normal;
  background-color: mediumpurple;
  color: white;
  padding: 4px 8px;
}
strong.test-html em {
  text-decoration: underline;
  font-style: initial;
}
```

The returned value is the generated style sheet object.

```js
assert(
  _ instanceof CSSStyleSheet,
  `want: ${CSSStyleSheet.name}, got: ${_?.constructor.name}`,
);
```

## JSON

Tag: `json`. A simple example:

```json
{
  "genus": "Attila",
  "species": "spadiceus"
}
```

JSON code blocks are parsed by the browser's `JSON` implementation. The
returned value is simply the decoded data.

```js
const [want, got] = ["Attila spadiceus", `${_?.genus} ${_?.species}`];
assert(want === got, `${want} !== ${got}`);
```

Parser errors will result in a failed block:

```json
KABOOM!!!
```

## YAML

Tags: `yaml`, `yml`. A simple example:

```yaml
genus: Cotinga
species: amabilis
```

The returned value is the entire decoded document. Note that currently only a
single document per code block is supported.

```js
const [want, got] = ["Cotinga amabilis", `${_?.genus} ${_?.species}`];
assert(want === got, `${want} !== ${got}`);
```

Parser errors are surfaced as usual:

```yaml
unknown: *anchor
```
