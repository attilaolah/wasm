const CLS_SRC: string = "src";
const CLS_OUT: string = "out";

const LANG_PREFIX: string = "language-";
const LANG_PREFIX_RE: RegExp = new RegExp(`^${LANG_PREFIX}`);

const MODULES: {
  [key: string]: (cell: HTMLDivElement) => void
} = {};

// Prepares code blocks for execution.
function prepareBlocks(root: HTMLElement): void {
  let id: number = 1;
  root
    .querySelectorAll(`pre>code[class^=${LANG_PREFIX}]`)
    .forEach((code: HTMLElement): void => prepareBlock(code, id++));
}

// Prepares a single code block for execution.
function prepareBlock(code: HTMLElement, id: number): void {
  const lang: string = ((
    Array
      .from(code.classList.values())
      .find((cls: string): boolean => !!cls.match(LANG_PREFIX_RE))
  ) ?? "").replace(LANG_PREFIX_RE, "");

  code.classList.add(CLS_SRC);
  const pre: HTMLPreElement = code.parentElement as HTMLPreElement;
  const cell: HTMLDivElement = document.createElement("div");
  cell.className = "cell";
  cell.dataset["id"] = id.toString();
  cell.id = `cell-${id}`;

  pre.parentNode.insertBefore(cell, pre);
  cell.append(pre)

  if (!MODULES.hasOwnProperty(lang)) {
    // Language not specified or unsupported, no run button needed.
    return;
  }

  const run: HTMLButtonElement = document.createElement("button");
  const icon: HTMLElement = document.createElement("span");

  run.className = "run";
  run.addEventListener("click", (evt: Event): void => {
    MODULES[lang](cell);
  });

  icon.className = "material-symbols-outlined";
  icon.innerText = "play_circle";

  run.append(icon, "RUN");

  const out: HTMLDivElement = document.createElement("div");
  out.className = CLS_OUT;

  cell.append(run, out);
}
