/*
 * Wrap C functions.
 *
 * We use a $ prefix to avoid clashing with Emscripten's names.
 */

// CMARK_GFM_EXTENSIONS_EXPORT
// void cmark_gfm_core_extensions_ensure_registered(void);
let $cmark_gfm_core_extensions_ensure_registered: () => void;

// CMARK_GFM_EXPORT
// cmark_parser *cmark_parser_new(int options);
let $cmark_parser_new: (options: number) => number;

// CMARK_GFM_EXPORT
// cmark_syntax_extension *cmark_find_syntax_extension(const char *name);
let $cmark_find_syntax_extension: (name: number) => number;

// CMARK_GFM_EXPORT
// int cmark_parser_attach_syntax_extension(cmark_parser *parser, cmark_syntax_extension *extension);
let $cmark_parser_attach_syntax_extension: (parser: number, extension: number) => number;

// CMARK_GFM_EXPORT
// void cmark_parser_feed(cmark_parser *parser, const char *buffer, size_t len);
let $cmark_parser_feed: (parser: number, buffer: number, len: number) => void;

// CMARK_GFM_EXPORT
// cmark_node *cmark_parser_finish(cmark_parser *parser);
let $cmark_parser_finish: (parser: number) => number;

// CMARK_GFM_EXPORT
// void cmark_parser_free(cmark_parser *parser);
let $cmark_parser_free: (parser: number) => void;

// CMARK_GFM_EXPORT
// char *cmark_render_html(cmark_node *root, int options, cmark_llist *extensions);
let $cmark_render_html: (root: number, options: number, extensions: number) => number;

// CMARK_GFM_EXPORT
// void cmark_node_free(cmark_node *node);
let $cmark_node_free: (node: number) => void;

// CMARK_EXPORT
// int cmark_version(void);
let $cmark_version_string: () => string;

// CMARK_GFM_EXPORT
// cmark_mem *cmark_get_default_mem_allocator();
let $cmark_get_default_mem_allocator: () => number;

// CMARK_GFM_EXPORT
// cmark_llist *cmark_list_syntax_extensions(cmark_mem *mem);
let $cmark_list_syntax_extensions: (mem: number) => number;

// CMARK_GFM_EXPORT
// void          cmark_llist_free      (cmark_mem         * mem,
//                                      cmark_llist       * head);
let $cmark_llist_free: (mem: number, head: number) => void;

// CMARK_GFM_EXPORT
// char *cmark_markdown_to_html(const char *text, size_t len, int options);
let $cmark_markdown_to_html: (text: number, len: number, options: number) => number;


const $CMARK_OPT_UNSAFE: number = 1 << 17;
const $CMARK_OPT_SMART: number = 1 << 10;
const $CMARK_OPT_LIBERAL_HTML_TAG: number = 1 << 12;
const $CMARK_OPT_FOOTNOTES: number = 1 << 13;
const $CMARK_OPT_TABLE_PREFER_STYLE_ATTRIBUTES: number = 1 << 15;
const $CMARK_OPT_FULL_INFO_STRING: number = 1 << 16;

function cmarkWrap(): void {
  // Use "number" return type since JSType does not define a "void" return type.
  $cmark_gfm_core_extensions_ensure_registered = cwrap("cmark_gfm_core_extensions_ensure_registered", "number", []);
  $cmark_parser_new = cwrap("cmark_parser_new", "number", ["number"]);
  $cmark_find_syntax_extension = cwrap("cmark_find_syntax_extension", "number", ["number"]);
  $cmark_parser_attach_syntax_extension = cwrap("cmark_parser_attach_syntax_extension", "number", ["number", "number"]);
  $cmark_parser_feed = cwrap("cmark_parser_feed", "number", ["number", "number", "number"]);
  $cmark_parser_finish = cwrap("cmark_parser_finish", "number", ["number"]);
  $cmark_parser_free = cwrap("cmark_parser_free", "number", ["number"]);
  $cmark_render_html = cwrap("cmark_render_html", "number", ["number", "number", "number"]);
  $cmark_node_free = cwrap("cmark_node_free", "number", ["number"]);
  $cmark_version_string = cwrap("cmark_version_string", "string", []);

  $cmark_get_default_mem_allocator = cwrap("cmark_get_default_mem_allocator", "number", []);
  $cmark_list_syntax_extensions = cwrap("cmark_list_syntax_extensions", "number", ["number"]);
  $cmark_llist_free = cwrap("cmark_llist_free", "number", ["number", "number"]);

  $cmark_markdown_to_html = cwrap("cmark_markdown_to_html", "number", ["number", "number", "number"]);
}
