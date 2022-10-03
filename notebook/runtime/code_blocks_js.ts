// Built-in JS module.
MODULES["js"] = (cell: HTMLDivElement): void => {
  const src: HTMLElement = cell.querySelector(`.${CLS_SRC}`);
  const out: HTMLElement = cell.querySelector(`.${CLS_OUT}`);

  let id: number = parseInt(cell.dataset["id"], 10)
  if (id > 1) {
    // There should be a previous cell, set up the _ variable.
    window["_"] = document.getElementById(`cell-${id-1}`)["_"];
  }

  let result: unknown;
  let ok: boolean = false;
  try {
    result = window["eval"](src.innerText);
    ok = true;
  } catch (e: unknown) {
    result = e;
  }

  cell["_"] = result;

  // Make the result available globally; useful for debugging.
  window["_"] = result;

  if (!ok) {
    // TODO: Display an error message!
  }

  if (result === undefined) {
    return;
  }

  const pre: HTMLPreElement = document.createElement("pre");
  pre.innerHTML = Prism.highlight(
    JSON.stringify(result, null, 2),
    Prism.languages.javascript,
    "javascript",
  );
  clearChildren(out);
  out.append(pre);

  Prism.highlightAllUnder(out)
};
