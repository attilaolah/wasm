// Built-in CSS module.
MODULES["css"] = (cell: HTMLDivElement): void => {
  const src: HTMLElement = cell.querySelector(`.${CLS_SRC}`);
  const out: HTMLElement = cell.querySelector(`.${CLS_OUT}`);

  const style: HTMLStyleElement = document.createElement("style");
  style.innerHTML = src.innerText;

  out.innerHTML = style.outerHTML;

  // _ points to the CSSStyleSheet instance.
  cell["_"] = Array
    .from(document.styleSheets)
    .find((css: CSSStyleSheet): boolean => css.ownerNode === style);
};
