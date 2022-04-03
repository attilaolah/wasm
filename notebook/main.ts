// These constants will be replaced when packaging.
const RUNTIME_JS = "./runtime/runtime_stripped_js.js";
const LAYOUT_HTML = "layout.html";
const MAIN_CSS = "style/main.css";

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

async function main() : Promise<void> {
  const notebook = new Notebook(new NotebookConfig(ownerDocument));

  // Export as a global for access from within code blocks:
  window["notebook"] = notebook;

  const jsMod = await importJS(RUNTIME_JS);
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
