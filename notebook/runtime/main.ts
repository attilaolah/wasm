const COPT: boolean = COMPILATION_MODE == "opt";

async function main(notebook: { ["root"]: HTMLElement }, layoutHTML: string): Promise<void> {
  const hl: SyntaxHighlighter = new SyntaxHighlighter();

  mdToHTML(notebook.root, layoutHTML);
  createTOC(notebook.root);
  prepareBlocks(notebook.root);

  await hl.run(notebook.root);
}

Module["onRuntimeInitialized"] = (): void => {
  cmarkWrap();

  // Expose the "main" method via the module.
  Module["main"] = main;
};

function loadJS(
  src: string,
  dataset: { [key: string]: string } = {},
  isAsync: boolean = false,
): Promise<void> {
  return new Promise<void>((resolve, reject): void => {
    const script: HTMLScriptElement = document.createElement("script");

    Object.entries(dataset).forEach(([key, value]) => {
      script.dataset[key] = value;
    });

    script.addEventListener("load", (ev: Event): void => {
      resolve();
    });
    script.addEventListener("error", reject);
    script.async = isAsync;
    script.src = src;

    document.head.appendChild(script);
  });
}
