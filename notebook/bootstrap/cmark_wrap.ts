// CMARK_EXPORT
// char *cmark_markdown_to_html(const char *text, size_t len, int options);
let cmarkMarkdownToHTML: (
  text: number,
  len: number,
  options: number,
) => number;

// CMARK_EXPORT
// int cmark_version(void);
let cmarkVersionString: () => string;

// #define CMARK_OPT_UNSAFE (1 << 17)
const CMARK_OPT_UNSAFE: number = 1 << 17;

function cmarkWrap() : void {
  cmarkMarkdownToHTML = cwrap("cmark_markdown_to_html", "number", ["number", "number", "number"]);
  cmarkVersionString = cwrap("cmark_version_string", "string", []);
}
