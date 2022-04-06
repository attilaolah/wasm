const NULL: number = 0;

const COMMENT_START: RegExp = /^\s*<!--/;
const COMMENT_END: RegExp = /-->\s*$/;

let gfmRegistered: boolean = false;

const allExtensions: Array<string> = [];
const defaultExtensions: Array<string> = [
  "autolink",
  "strikethrough",
  "table",
  "tasklist",
]

const defaultOptions: number = (
  $CMARK_OPT_UNSAFE |
  $CMARK_OPT_SMART |
  $CMARK_OPT_LIBERAL_HTML_TAG |
  $CMARK_OPT_FOOTNOTES |
  $CMARK_OPT_TABLE_PREFER_STYLE_ATTRIBUTES |
  $CMARK_OPT_FULL_INFO_STRING
);

class MDParser {
  parser: number;
  options: number;

  constructor(options: number, extensions: Array<string>) {
    if (!gfmRegistered) {
      $cmark_gfm_core_extensions_ensure_registered();
      listExtensions().forEach((name: string): void => {
        allExtensions.push(name);
      });
      gfmRegistered = true;
    }

    this.parser = $cmark_parser_new(options);
    this.options = options;

    extensions.forEach((name: string): void => {
      const extPtr: number = findExtension(name);
      if (extPtr) {
        if (!$cmark_parser_attach_syntax_extension(this.parser, extPtr)) {
          console.warn(`GFM extension ${JSON.stringify(name)} could not be attached`);
        }
      }
    });
  }

  toHTML(markdown: string): string {
    const mdSize: number = lengthBytesUTF8(markdown) + 1;
    const mdPtr: number = _malloc(mdSize);
    stringToUTF8(markdown, mdPtr, mdSize);

    $cmark_parser_feed(this.parser, mdPtr, mdSize - 1);
    let doc: number = $cmark_parser_finish(this.parser);
    _free(mdPtr);

    let html: number = $cmark_render_html(doc, this.options, NULL);
    $cmark_node_free(doc);

    const result: string = UTF8ToString(html);
    _free(html);
    return result;
  }

  free() {
    $cmark_parser_free(this.parser);
  }
};

function findExtension(name: string): number {
  const nameSize: number = lengthBytesUTF8(name) + 1;
  const namePtr: number = _malloc(nameSize);
  stringToUTF8(name, namePtr, nameSize);
  const extPtr: number = $cmark_find_syntax_extension(namePtr);
  _free(namePtr);

  if (!extPtr) {
    console.warn(`GFM extension ${JSON.stringify(name)} not found; available extensions: [${allExtensions.join(", ")}]`);
  }

  return extPtr;
}

function listExtensions(): Array<string> {
  const mem: number = $cmark_get_default_mem_allocator();
  const extensions: number = $cmark_list_syntax_extensions(mem);

  // We build with MAXIMUM_MEMORY = 2GB, so assume 32-bit pointer size.
  const ptrs: number = getNativeTypeSize("void*");
  if (ptrs != 4) {
    throw `unexpected pointer size: ${ptrs}`;
  }

  let pos: number = extensions;
  let result: Array<string> = [];
  while (true) {
    let next: number = HEAPU32[pos / ptrs + 0];
    let data: number = HEAPU32[pos / ptrs + 1];
    let name: number = HEAPU32[(data / ptrs) + 5];
    result.push(UTF8ToString(name));

    if (!next) {
      break;
    }

    pos = HEAPU32[next / ptrs];
  }

  $cmark_llist_free(mem, extensions);

  return result;
}

function mdToHTML(root: HTMLElement, layoutHTML: string): void {
  // Undo any escaping that was inserted by the browser.
  let content: string = root.innerHTML;

  // The page could be commented out to avoid escaping issues.
  if (content.match(COMMENT_START)) {
    content = content.replace(COMMENT_START, "").replace(COMMENT_END, "");
  }

  const parser: MDParser = new MDParser(defaultOptions, defaultExtensions);
  const html: string = parser.toHTML(content);
  parser.free();

  const tpl: HTMLTemplateElement = document.createElement("template");
  tpl.innerHTML = layoutHTML;
  tpl.content.querySelector("#content").innerHTML = html;

  // If the document has no title, set it to the first heading.
  if (!document.title) {
    const h1: HTMLHeadingElement = tpl.content.querySelector("h1");
    if (h1) {
      document.title = h1.innerText;
    }
  }

  // Clear the root node.
  // See https://stackoverflow.com/a/3955238 for why the first/last child combo.
  while (root.firstChild) {
    root.removeChild(root.lastChild);
  }

  root.appendChild(tpl.content);

  ensureMetaCharset();
  showLicense(root);
}

// DOM accessors:
function getContent(): HTMLElement {
  return document.getElementById("content");
}

function querySelector(query: string): HTMLElement {
  return getContent().querySelector(query);
}

function querySelectorAll(query: string): NodeList {
  return getContent().querySelectorAll(query);
}

function ensureMetaCharset(): void {
  if (!document.querySelector("meta[charset]")) {
    const meta: HTMLMetaElement = document.createElement("meta");
    meta.setAttribute("charset", "utf-8");
    document.head.insertBefore(meta, document.head.firstChild);
  }
}

// Show the theme license as a link.
function showLicense(root: HTMLElement): void {
  const container: HTMLElement = root.querySelector(".page-footer-legal-text");

  // Make the name selectable by moving it to the DOM.
  const nameCls: string = "theme-name";
  const nameEl: HTMLElement = container.querySelector(`.${nameCls}`);
  const [, after] = getBeforeAfter(nameEl);
  nameEl.classList.remove(nameCls);
  nameEl.innerText += after;

  // Make the license clickable by wrapping it in an achor tag:
  const licenseCls: string = "theme-license";
  const licenseEl: HTMLElement = container.querySelector(`.${licenseCls}`)
  const [name, url] = getBeforeAfter(licenseEl);
  licenseEl.classList.remove(licenseCls);

  const a: HTMLAnchorElement = document.createElement("a");
  a.textContent = name;
  a.href = url;

  licenseEl.innerHTML = "";
  licenseEl.appendChild(a);
}

function getBeforeAfter(el: HTMLElement): [string, string] {
  return ["::before", "::after"]
    .map((selector: string): CSSStyleDeclaration => window.getComputedStyle(el, selector))
    .map((sd: CSSStyleDeclaration): string => sd.content)
    .map((content: string): string => {
      return content === "none" ? null : JSON.parse(content)
    }) as [string, string];
}
