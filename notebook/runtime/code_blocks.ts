const CLS_SRC: string = "src";
const CLS_OUT: string = "out";

const LANG_PREFIX: string = "language-";
const LANG_PREFIX_RE: RegExp = new RegExp(`^${LANG_PREFIX}`);

const MODULES: {
  [key: string]: (cell: HTMLDivElement) => void
} = {};

const RUN_ALL: Array<() => void> = [];

// Prepares code blocks for execution. Returns a function that executes
// auto-run, which should be executed once the syntax highlighter is ready.
function prepareBlocks(root: HTMLElement): () => void {
  let id: number = 1;
  root
    .querySelectorAll(`pre>code[class^=${LANG_PREFIX}]`)
    .forEach((code: HTMLElement): void => prepareBlock(code, id++));

  return (): void => RUN_ALL.forEach((fn: () => void): void => fn());
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

  RUN_ALL.push((): void => MODULES[lang](cell));

  const controls: HTMLDivElement = document.createElement("div");
  controls.className = "controls";

  const run: HTMLButtonElement = document.createElement("button");
  run.className = "run";
  run.addEventListener("click", (evt: Event): void => {
    MODULES[lang](cell);
  });

  const icon: HTMLElement = document.createElement("span");
  icon.className = "material-symbols-outlined icon";
  icon.innerText = "play_circle";

  controls.append(run);
  run.append(icon, "Run snippet");

  const out: HTMLDivElement = document.createElement("div");
  out.className = CLS_OUT;

  cell.append(out, controls);
}
