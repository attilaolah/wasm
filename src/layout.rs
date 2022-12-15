use pulldown_cmark::{html, Options, Parser};
use wasm_bindgen::JsValue;
use web_sys::{Document, HtmlElement};

use crate::notebook_config;

pub fn display_content(doc: &Document, root: &HtmlElement) -> Result<(), JsValue> {
    let inner_html = root.inner_html();
    let mut markdown_src = inner_html.trim();
    markdown_src = markdown_src.strip_prefix("<!--").unwrap_or(markdown_src);
    markdown_src = markdown_src.strip_suffix("-->").unwrap_or(markdown_src);
    markdown_src = markdown_src.trim();

    let md_doc = notebook_config::parse_doc(&markdown_src);
    markdown_src = &md_doc.content;

    let parser = Parser::new_ext(markdown_src, Options::all());

    let mut buf = String::new();
    html::push_html(&mut buf, parser);

    let pre = doc.create_element("pre")?;
    pre.set_inner_html(&buf);

    // TODO: Just to see if it worked:
    if md_doc.metadata.autorun() {
        pre.class_list().add_1("autorun")?;
    }

    clear_children(root)?;
    root.append_child(&pre)?;

    Ok(())
}

// Clear the node.
// See https://stackoverflow.com/a/3955238 for why the first/last child combo.
fn clear_children(el: &HtmlElement) -> Result<(), JsValue> {
    while !el.first_child().is_none() {
        if let Some(node) = el.last_child() {
            el.remove_child(&node)?;
        }
    }

    Ok(())
}
