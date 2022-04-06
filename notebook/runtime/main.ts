async function main(notebook: { ["root"]: HTMLElement }, layoutHTML: string) : Promise<void> {
  const hl: SyntaxHighlighter = new SyntaxHighlighter();

  mdToHTML(notebook.root, layoutHTML);
  createTOC(notebook.root);

  await hl.run();
}

Module["onRuntimeInitialized"] = () : void => {
  cmarkWrap();

  // Expose the "main" method via the module.
  Module["main"] = main;
};

function loadJS(
  src: string,
  glob: string = "",
  async: boolean = false,
  dataset: { [key: string]: string } = {},
) : Promise<unknown> {
  return new Promise<unknown>((resolve, reject) : void => {
    const script: HTMLScriptElement = document.createElement("script");

    Object.entries(dataset).forEach(([key, value]) => {
      script.dataset[key] = value;
    });

    script.addEventListener("load", (ev: Event): void => {
      resolve(glob ? window[glob] : null);
    });
    script.addEventListener("error", reject);
    script.async = async;
    script.src = src;

    document.head.appendChild(script);
  });
}
