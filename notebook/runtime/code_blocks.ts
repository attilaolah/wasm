const LANG_PREFIX: string = "language-";
const LANG_PREFIX_RE: RegExp = new RegExp(`^${LANG_PREFIX}`);

const MODULES: {
  [key: string]: (cell: HTMLDivElement) => void
} = {};

// Prepares code blocks for execution.
function prepareBlocks(root: HTMLElement): void {
  root
    .querySelectorAll(`pre>code[class^=${LANG_PREFIX}]`)
    .forEach(prepareBlock);
}


// Prepares a single code block for execution.
function prepareBlock(code: HTMLElement): void {
  const lang: string = ((
    Array
      .from(code.classList.values())
      .find((cls: string): boolean => !!cls.match(LANG_PREFIX_RE))
  ) ?? "").replace(LANG_PREFIX_RE, "");

  if (!MODULES.hasOwnProperty(lang)) {
    // Language not specified or unsupported.
    return;
  }

  const pre: HTMLPreElement = code.parentElement as HTMLPreElement;

  const cell: HTMLDivElement = newDiv("cell");

  const src: HTMLDivElement = newDivChild(cell, "src");
  const srcGutter: HTMLDivElement = newDivChild(src, "gut");
  const srcRun: HTMLButtonElement = document.createElement("button");
  srcRun.className = "run";
  srcRun.innerText = "RUN";
  srcRun.addEventListener("click", (evt: Event): void => {
    MODULES[lang](cell);
  });
  srcGutter.append(srcRun);

  const dst: HTMLDivElement = newDivChild(cell, "dst");
  const dstGutter: HTMLDivElement = newDivChild(dst, "gut");
  const dstOut: HTMLDivElement = newDivChild(dst, "out");

  pre.parentNode.insertBefore(cell, pre);
  src.append(pre);
}

// Built-in HTML module.
MODULES["html"] = (cell: HTMLDivElement): void => {
  const code: HTMLElement = cell.querySelector(".src code");
  const out: HTMLElement = cell.querySelector(".dst>.out");

  out.innerHTML = code.innerText;
};

// Built-in CSS module.
MODULES["css"] = (cell: HTMLDivElement): void => {
  const code: HTMLElement = cell.querySelector(".src code");
  const out: HTMLElement = cell.querySelector(".dst>.out");

  const style: HTMLStyleElement = document.createElement("style");
  style.innerHTML = code.innerText;
  out.innerHTML = style.outerHTML;
};


// TODO: Move this somewhere!
function newDiv(cls: string): HTMLDivElement {
  const div: HTMLDivElement = document.createElement("div");
  div.className = cls;
  return div;
}

function newDivChild(parent: HTMLElement, cls: string): HTMLDivElement {
  const div: HTMLDivElement = newDiv(cls);
  parent.append(div);
  return div;
}
