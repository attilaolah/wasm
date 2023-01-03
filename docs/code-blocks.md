---
autorun: true
---

# Code Blocks

The following languages are supported out of the box:

## JavaScript {#js}

Tags: `javascript`, `js`. Simple example:

```js
"Hello, JavaScript!";
```

The returned value of the previous block accessible as `_`:

```js
self.assert = (test, message) => {
  if (!test) {
    throw new Error(`assertion failed: ${message}`);
  }
}

assert(
  Object(_) instanceof String,
  `want: ${String.name}, got: ${_?.constructor.name}`,
);
```

Returned `Node` objects are directly injected to the DOM:

```js
const em = document.createElement("em");
em.innerText = navigator.userAgent;

const div = document.createElement("div");
div.append("User-Agent: ", em);

div;
```

```js
assert(
  Object(_) instanceof Node,
  `want: ${Node.name}, got: ${_?.constructor.name}`,
);
```

## HTML

Tag: `html`. Simple example:

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

Tag: `css`. Simple example:

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

Tag: `json`. Simple example:

```json
{
  "genus": "Attila",
  "species": "spadiceus"
}
```

The returned value is simply the decoded data.

```js
const [want, got] = ["Attila spadiceus", `${_?.genus} ${_?.species}`];
assert(want === got, `${want} !== ${got}`);
```

## YAML

Tags: `yaml`, `yml`. Simple example:

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

TODO: Anchor support doesn't work very well at the moment.

```yaml
- &genus: Cotinga
  species: amabilis
- genus: *genus
  species: cayana
```

The returned value is an array containing the parsed documents.

```js
assert(_?.length === 2, `want 2, got: ${_?.length}`);
```

## CSV

## Fetch

