const NOTEBOOK_HTML = "notebook.html";
const RUNTIME_JS = "./modules/runtime.js";
const THEME_CSS = "themes/mdn-yari.css";

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
    const parts: Array<string> = doc.body.textContent.split(/```(?:notebook-config|meta)\b/, 2);
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
  const callback = runtime["main"] as (HTMLElement, string) => void;

  callback(notebook, await layoutHTML);

  // Wait for CSS to load, then clean up.
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

  link.addEventListener("load", (evt: Event) : void => {
    console.log("LINK resolve!");
    resolve(null);
  });

  link.addEventListener("error", (evt: Event) : void => {
    console.log("LINK reject!");
    reject();
  });

  addLink(link);
});

// Font loading is fire-and-forget.
// We can live without fonts, and we use font-display: swap anyway.
setTimeout(fontCSS, 0);

const cleanups: Array<() => void> = [
  () : void => { currentScript.remove(); },
];

if ((ownerDocument.readyState === "complete") || currentScript.async || currentScript.defer) {
  // Assume the DOM is already loaded and ready to be parsed.
  main();
} else {
  prepare();
  // Wait for DOMContentLoaded.
  ownerDocument.addEventListener("DOMContentLoaded", (evt: Event) : void => {
    main();
  });
}
