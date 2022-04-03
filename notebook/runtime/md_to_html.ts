function mdToHTML(root: HTMLElement, layoutHTML: string) : void {
  const srcHTML: string = root.innerHTML;
  const size: number = lengthBytesUTF8(srcHTML);
  const markdown: number = __malloc(size);
  stringToUTF8(srcHTML, markdown, size);

  const html: number = cmarkMarkdownToHTML(markdown, size - 1, CMARK_OPT_UNSAFE);
  __free(markdown);

  const dstHTML: string = UTF8ToString(html);
  __free(html);

  const tpl: HTMLTemplateElement = document.createElement("template");
  tpl.innerHTML = layoutHTML;
  tpl.content.querySelector("#content").innerHTML = dstHTML;

  // If the document has no title, set it to the first heading.
  if (!document.title) {
    const h1: HTMLHeadingElement = tpl.content.querySelector("h1");
    if (h1) {
      document.title = h1.innerText;
    }
  }

  // Clear the root node.
  // See https://stackoverflow.com/a/3955238 for why the first/last child combo.
  while (root.firstChild) {
    root.removeChild(root.lastChild);
  }

  root.appendChild(tpl.content);
}
