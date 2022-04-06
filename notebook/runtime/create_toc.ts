function createTOC(root: HTMLElement): void {
  const document: HTMLDocument = root.ownerDocument;

  const toc: HTMLUListElement = root.querySelector("#toc-entries");
  root.querySelectorAll("#content h2:not(.no-toc)").forEach((h2: HTMLHeadingElement): void => {
    const li: HTMLLIElement = document.createElement("li");
    li.className = "document-toc-item"

    const a: HTMLAnchorElement = document.createElement("a");
    a.textContent = h2.innerText;
    a.className = "document-toc-link";
    a.href = `#${h2.id}`;

    li.appendChild(a);
    toc.appendChild(li);
  });
}
