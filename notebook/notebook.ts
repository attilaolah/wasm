(() : void => {
  const script = document.currentScript as HTMLScriptElement;
  const settings = script.dataset;

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

  // Now load the bootstrap script.
  // First see if it was explicitly passed via a dataset attribute.
  let url: string;
  if (settings.bootstrap) {
    url = settings.bootstrap;
  } else {
    const groups = script.src.match(/(?<prefix>.+\/)[^/]+(?<ext>\..*)/).groups;
    url = `${groups.prefix}bootstrap${groups.ext}`;
  }
  const bootstrap = document.createElement("script");
  bootstrap.addEventListener("load", async (evt: Event) : Promise<void> => {
    const name = "BOOTSTRAP";
    const ctor = window[name];
    window[name] = undefined;
    const obj = await ctor();
    obj.bootstrap(root());
    cleanup();
  });
  bootstrap.async = true;
  bootstrap.src = url;
  script.parentElement.appendChild(bootstrap);
})();
