const PRISM_VERSION: string = "1.29.0";
const PRISM_URL_PREFIX: string = `https://unpkg.com/prismjs@${PRISM_VERSION}`;

class SyntaxHighlighter {
  init: Promise<[void, void]>;

  constructor() {
    // Parallel fetch both prism-core and prism-autoloader.
    this.init = Promise.all([
      loadJS(`${PRISM_URL_PREFIX}/components/prism-core${COPT ? ".min" : ""}.js`, {
        manual: "",
      }),
      loadJS(`${PRISM_URL_PREFIX}/plugins/autoloader/prism-autoloader${COPT ? ".min" : ""}.js`),
    ]);
  }

  async run() {
    // If there are any notebook-config blocks, remove the language-xxxx class to
    // prevent it from triggering a pointless lookup during syntax highlighting.
    querySelectorAll(`pre>code.language-notebook-config`)
      .forEach((code: HTMLElement): void => {
        code.classList.remove("language-notebook-config");
        code.classList.add("language-json");
      });

    await this.init;
    Prism.plugins.autoloader.use_minified = COPT;
    Prism.highlightAllUnder(getContent());
  }
};
