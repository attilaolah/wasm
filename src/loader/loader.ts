const currentScript: HTMLScriptElement =
  (document["currentScript"] || Array.from(
    // In case this script is loaded as a module:
    document.querySelectorAll('script[type=module]'),
  ).pop()) as HTMLScriptElement;
const ownerDocument = currentScript.ownerDocument;
const ownerHead = ownerDocument.head;

const DIR = currentScript.src.replace(/\/*[^/]*$/, '')
const STYLE_CSS = `${DIR}/style.css`;

class Notebook {
  mod: { [key: string]: (src: string) => any } = {};
}

export function preload(): void {
  loadStyle();
  loadFonts();

  window["notebook"] = new Notebook();
}

function loadStyle(): void {
  addLink(mkLink(STYLE_CSS));
}

function loadFonts(): void {
  const fontsAPI: string = "https://fonts.googleapis.com"
  addLink(mkLink(fontsAPI, true));
  addLink(mkLink("https://fonts.gstatic.com", true, true));
  addLink(mkLink(`${fontsAPI}/css2?family=Inter:wght@400;500;700&family=Roboto+Condensed&display=swap`));
  addLink(mkLink(`${fontsAPI}/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200`));
}

function mkLink(href: string, preConnect: boolean = false, crossOrigin: boolean = false): HTMLLinkElement {
  const link: HTMLLinkElement = document.createElement("link");
  link.href = href;
  link.rel = preConnect ? "preconnect" : "stylesheet";
  if (crossOrigin) {
    link.crossOrigin = "";
  }
  return link;
}

function addLink(link: HTMLLinkElement): void {
  ownerHead.appendChild(link);
}
