// TODO: AUTO-wrap this into an IIFE!

const BOOTSTRAP_JS = "bootstrap/bootstrap_trim_js.js";
const LAYOUT_HTML = "layout.html";
const MAIN_CSS = "style/main.css";

const script = document.currentScript as HTMLScriptElement;
const head = script.ownerDocument.head;
const settings = script.dataset;

if (!("bootstrap" in settings)) {
  settings.bootstrap = [
    script.src.match(/(.*\/)[^\/]*/)[1],
    BOOTSTRAP_JS,
  ].join("");
}

const style = document.createElement("style");
style.className = "loading";

if (settings.loading === "text") {
  // The loading style was explicitly set to text: pre-format text soure.
  style.textContent = ":root { font-family: monospace; white-space: pre-wrap; }"
} else if ((settings.loading === "blank") || !(script.async || script.defer)) {
  // Blank loading style is also the default unless the script was loaded asynchronously.
  style.textContent = ":root { display: none !important; }";
}

script.parentElement.appendChild(style);

// Once the loading is done, remove the style:
// TODO: Call this function after loading has completed!
const cleanup = () : void => {
  script.remove();
  style.remove();
};

// Which part of the page to process?
// By default, we process the entire <body>, but this too can be configured.
// This is evaluated lazily because the root element might not exist just yet.
const root = () : HTMLElement => settings.root
  ? document.querySelector(settings.root)
  : document.body;

const loadBootstrapJS = new Promise((resolve, reject) => {
  const script: HTMLScriptElement = document.createElement("script");
  script.async = true;

  script.addEventListener("load", async (evt: Event) : Promise<void> => {
    const moduleName = "BOOTSTRAP";
    const ctor = window[moduleName];
    window[moduleName] = undefined;
    const obj = await ctor();

    obj.bootstrap(root(), await loadLayoutHTML);

    console.log("SCRIPT resolve!");
    resolve(null);
  });

  script.addEventListener("error", (evt: Event) : void => {
    console.log("SCRIPT reject!");
    reject();
  });

  script.src = settings.bootstrap;
  head.appendChild(script);
});

const loadMainCSS = new Promise((resolve, reject) => {
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
  head.appendChild(link);
});

const loadLayoutHTML = new Promise<string>(async (resolve) => {
  const res: Response = await fetch(LAYOUT_HTML);
  resolve(await res.text());
});

Promise.all([
  loadBootstrapJS,
  loadMainCSS,
  loadLayoutHTML,
]).then(cleanup);
