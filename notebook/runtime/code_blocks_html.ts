// Built-in HTML module.
MODULES["html"] = (cell: HTMLDivElement): void => {
  const src: HTMLElement = cell.querySelector(`.${CLS_SRC}`);
  const out: HTMLElement = cell.querySelector(`.${CLS_OUT}`);

  out.innerHTML = src.innerText;

  // _ points to the last element.
  cell["_"] = out.lastElementChild;
};
