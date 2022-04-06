const NOTEBOOK_HTML: string = "notebook.html";
const RUNTIME_JS: string = "./modules/runtime.mjs";
const THEME_CSS: string = "themes/mdn-yari.css";

const COPT: boolean = COMPILATION_MODE == "opt";

// PrismJS version to use:
const PRISM_VERSION: string = "1.27.0";

const currentScript = Array.from(
  document.querySelectorAll('script[type=module]'),
).pop() as HTMLScriptElement;
const ownerDocument = currentScript.ownerDocument;
const ownerHead = ownerDocument.head;

class Notebook {
  config: NotebookConfig;
  root: HTMLElement;

  constructor(config: NotebookConfig) {
    // Export properties.
    /** @suppress {checkTypes} */
    this["config"] = config;
    /** @suppress {checkTypes} */
    this["root"] = config.root
      ? ownerDocument.querySelector(config.root)
      : ownerDocument.body;
  }
};

class NotebookConfig {
  root: string;
  autorun: Array<string> | boolean;

  constructor(doc: HTMLDocument) {
    let obj: any = {};
    const parts: Array<string> = doc.body.textContent.split(/```notebook-config\b/, 2);
    if (parts.length === 2) {
      const config: string = parts[1].split(/```/, 2)[0];
      obj = JSON.parse(config);
    }

    // Export properties.
    /** @suppress {checkTypes} */
    this["root"] = obj.hasOwnProperty("root")
      ? obj["root"]
      : "body";
    /** @suppress {checkTypes} */
    this["autorun"] = obj.hasOwnProperty("autorun")
      ? obj["autorun"]
      : true;
  }
};

let importJS: (string) => Promise<{
  ["default"]: any,
}>;

const jsModP: Promise<{
  ["default"]: any,
}> = importJS(RUNTIME_JS);

async function main() : Promise<void> {
  const notebook = new Notebook(new NotebookConfig(ownerDocument));

  // Export as a global for access from within code blocks:
  window["notebook"] = notebook;

  const jsMod = await jsModP;
  const runtime: EmscriptenModule = await new jsMod.default();

  // Export the runtime via the global notebook object.
  notebook["runtime"] = runtime;

  // Run the main function of the runtime:
  const callback = runtime["main"] as (HTMLElement, string) => Promise<void>;
  await callback(notebook, await layoutHTML);

  // Wait for CSS to load, then clean up.
  // TODO: Do the cleanup sooner; but hand off to the runtime.
  await mainCSS;
  cleanups.forEach((cleanup) => cleanup());
}

function prepare() : void {
  const style = ownerDocument.createElement("style");
  // Blank loading style, unless the script was loaded asynchronously.
  style.textContent = ":root{display:none!important}";

  ownerHead.append(style);
  cleanups.push(() : void => {
    style.remove();
  });
}

const layoutHTML = new Promise<string>(async (resolve) => {
  const res: Response = await fetch(NOTEBOOK_HTML);
  resolve(await res.text());
});

function fontCSS() : void {
  const api: string = "https://fonts.googleapis.com"
  addLink(mkLink(api, true));
  addLink(mkLink("https://fonts.gstatic.com", true, true));
  addLink(mkLink(`${api}/css2?family=Inter&display=swap`));
}

function highlightCSS() : void {
  const darkTheme: boolean = (
    window.matchMedia &&
    window.matchMedia('(prefers-color-scheme: dark)').matches
  );
  const prism = `https://unpkg.com/prismjs@${
    PRISM_VERSION
  }/themes/prism${
    darkTheme ? "-dark" : ""
  }${
    COPT ? ".min" : ""
  }.css`;
  addLink(mkLink(prism));
}

function mkLink(href: string, preConnect: boolean = false, crossOrigin: boolean = false) : HTMLLinkElement {
  const link: HTMLLinkElement = document.createElement("link");
  link.href = href;
  link.rel = preConnect ? "preconnect" : "stylesheet";
  if (crossOrigin) {
    link.crossOrigin = "";
  }
  return link;
}

function addLink(link: HTMLLinkElement) : void {
  ownerHead.appendChild(link);
}

const mainCSS = new Promise((resolve, reject) => {
  const link: HTMLLinkElement = mkLink(THEME_CSS);

  link.addEventListener("load", (ev: Event) : void => {
    resolve(null);
  });

  link.addEventListener("error", (ev: Event) : void => {
    reject();
  });

  addLink(link);
});

// Font loading is fire-and-forget.
// We can live without fonts, and we use font-display: swap anyway.
setTimeout(fontCSS, 0);

// Syntax highlighting is also non-essential.
setTimeout(highlightCSS, 0);

const cleanups: Array<() => void> = [
  () : void => { currentScript.remove(); },
];

if ((ownerDocument.readyState === "complete") || currentScript.async || currentScript.defer) {
  // Assume the DOM is already loaded and ready to be parsed.
  main();
} else {
  prepare();
  // Wait for DOMContentLoaded.
  ownerDocument.addEventListener("DOMContentLoaded", (ev: Event) : void => {
    main();
  });
}
