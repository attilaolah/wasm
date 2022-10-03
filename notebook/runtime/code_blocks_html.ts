// Built-in HTML module.
MODULES["html"] = (cell: HTMLDivElement): void => {
  const src: HTMLElement = cell.querySelector(`.${CLS_SRC}`);
  const out: HTMLElement = cell.querySelector(`.${CLS_OUT}`);

  out.classList.add("ok");
  out.classList.remove("fail");
  out.innerHTML = src.innerText;

  // _ points to the last element.
  cell["_"] = out.lastElementChild;
};
