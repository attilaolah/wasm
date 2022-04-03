// These constants will be replaced when packaging.
const BOOTSTRAP_JS = "bootstrap/bootstrap_trim_js.js";
const LAYOUT_HTML = "layout.html";
const MAIN_CSS = "style/main.css";

const currentScript = document.currentScript as HTMLScriptElement;
const ownerDocument = currentScript.ownerDocument;
const ownerHead = ownerDocument.head;

const bootstrapURL = [
  currentScript.src.match(/(.*\/)[^\/]*/)[1],
  BOOTSTRAP_JS,
].join("");

class Notebook {
  /** @nocollapse */
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

let notebook: Notebook;
function main() : void {
  notebook = new Notebook(new NotebookConfig(ownerDocument));
  window["notebook"] = notebook;

  // The bootstrap function is async, but we don't need to wait.
  bootstrap(notebook);
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

async function bootstrap(notebook: Notebook) : Promise<void> {
  const mod: EmscriptenModule = await bootstrapJS;
  const callback = mod["bootstrap"] as (HTMLElement, string) => void;
  callback(notebook.root, await layoutHTML);
  await mainCSS;

  cleanups.forEach((cleanup) => cleanup());
}

const bootstrapJS = new Promise<EmscriptenModule>((resolve, reject) => {
  const script: HTMLScriptElement = ownerDocument.createElement("script");
  script.async = true;

  script.addEventListener("load", async (evt: Event) => {
    const moduleName = "BOOTSTRAP";
    const ctor = window[moduleName];
    window[moduleName] = undefined; // make private
    resolve(await ctor());
    script.remove();
  });

  script.addEventListener("error", reject);

  script.src = bootstrapURL;
  ownerHead.appendChild(script);
});

const layoutHTML = new Promise<string>(async (resolve) => {
  const res: Response = await fetch(LAYOUT_HTML);
  resolve(await res.text());
});

const mainCSS = new Promise((resolve, reject) => {
  const link: HTMLLinkElement = document.createElement("link");
  link.rel = "stylesheet";

  link.addEventListener("load", (evt: Event) : void => {
    console.log("LINK resolve!");
    resolve(null);
  });

  link.addEventListener("error", (evt: Event) : void => {
    console.log("LINK reject!");
    reject();
  });

  link.href = MAIN_CSS;
  ownerHead.appendChild(link);
});

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
