const PRISM_PREFIX: string = "https://unpkg.com/prismjs@1.27.0";

class SyntaxHighlighter {
  init: Promise<[typeof Prism, unknown]>;

  constructor() {
    // Parallel fetch both prism-core and prism-autoloader.
    this.init = Promise.all([
      loadJS(`${PRISM_PREFIX}/components/prism-core.js`, "Prism", false, {
        manual: "",
      }) as Promise<typeof Prism>,
      loadJS(`${PRISM_PREFIX}/plugins/autoloader/prism-autoloader.js`),
    ]);
  }

  async prism() : Promise<typeof Prism> {
    return (await this.init)[0];
  }

  async run() {
    // If there are any notebook-config blocks, remove the language-xxxx class to
    // prevent it from triggering a pointless lookup during syntax highlighting.
    querySelectorAll(`pre>code.language-notebook-config`)
      .forEach((code: HTMLElement): void => {
        code.classList.remove("language-notebook-config");
        code.classList.add("language-json");
      });

    (await this.prism()).highlightAllUnder(getContent());
  }
};
