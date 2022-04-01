function mdToHTML(root: HTMLElement) : void {
  const srcHTML: string = root.innerHTML;
  const size: number = lengthBytesUTF8(srcHTML);
  const markdown: number = _malloc(size);
  stringToUTF8(srcHTML, markdown, size);

  const html: number = cmarkMarkdownToHTML(markdown, size - 1, CMARK_OPT_UNSAFE);
  _free(markdown);

  const dstHTML: string = UTF8ToString(html);
  _free(html);

  const main: HTMLElement = document.createElement("main");
  main.setAttribute("role", "main");
  main.className = "main-content";
  main.id = "content";
  main.innerHTML = dstHTML;

  // If the document has no title, set it to the first heading.
  if (!document.title) {
    const h1: HTMLHeadingElement = main.querySelector("h1");
    if (h1) {
      document.title = h1.innerText;
    }
  }

  // See https://stackoverflow.com/a/3955238.
  while (root.firstChild) {
    root.removeChild(root.lastChild);
  }
  root.appendChild(main);
}
