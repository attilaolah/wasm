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

  clearChildren(out);

  if (result && !ok) {
    out.classList.add("fail");
    out.classList.remove("ok");

    const pre: HTMLPreElement = document.createElement("pre");
    pre.innerText = result.toString();
    out.append(pre);
    return;
  }

  out.classList.add("ok");
  out.classList.remove("fail");

  if (result instanceof Node) {
    out.append(result);
    return;
  }

  if (result === undefined) {
    return;
  }

  const pre: HTMLPreElement = document.createElement("pre");
  pre.className = "language-json";

  const code: HTMLElement = document.createElement("code");
  code.innerHTML = JSON.stringify(result, null, 2);
  pre.append(code);
  out.append(pre);

  // Apply JSON highlighting:
  Prism.highlightAllUnder(out)
};
