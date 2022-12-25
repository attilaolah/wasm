use js_sys::Error;
use wasm_bindgen::JsCast;
use web_sys::{
    console, HtmlButtonElement, HtmlDivElement, HtmlElement, HtmlPreElement, MouseEvent,
};

use crate::dom_helpers::{create_element, document, not_defined, on_el_click, wrong_type};

static SRC: &str = "src";
static OUT: &str = "out";
static PREFIX: &str = "language-";

pub fn prepare_all() -> Result<(), Error> {
    let codes = document()?.query_selector_all(&format!("pre>code[class^={}]", PREFIX))?;
    for i in 0..codes.length() {
        if let Some(node) = codes.get(i) {
            let el: HtmlElement = node.dyn_into().or_else(wrong_type("query_selector_all"))?;
            prepare_block(&el, i)?;
        }
    }

    Ok(())
}

// Prepares a single code block for execution.
fn prepare_block(code: &HtmlElement, id: u32) -> Result<(), Error> {
    let lang = language_class(&code);

    code.class_list().add_1(SRC)?;
    let pre: HtmlPreElement = code
        .parent_element()
        .ok_or_else(not_defined("parent_element"))?
        .dyn_into()
        .or_else(wrong_type("parent_element"))?;
    let cell: HtmlDivElement = create_element("div")?;
    cell.set_class_name("cell");
    cell.dataset().set("id", &id.to_string())?;
    cell.set_id(&format!("cell-{}", id));

    pre.parent_element()
        .ok_or_else(not_defined("parent_element"))?
        .insert_before(&cell, Some(&pre))?;
    cell.append_child(&pre)?;

    // TODO: Stop here if running this block is not supported.

    let controls: HtmlDivElement = create_element("div")?;
    controls.set_class_name("controls");

    let run: HtmlButtonElement = create_element("button")?;
    run.set_class_name("run");
    on_el_click(&run, &on_run)?;

    let icon: HtmlElement = create_element("span")?;
    icon.class_list()
        .add_2("material-symbols-outlined", "icon")?;
    icon.set_inner_text("play_circle");

    let text: HtmlElement = create_element("span")?;
    text.set_inner_text("Run block");

    controls.append_child(&run)?;
    run.append_with_node_2(&icon, &text)?;

    let out: HtmlDivElement = create_element("div")?;
    out.set_class_name(OUT);

    cell.append_with_node_2(&out, &controls)?;

    Ok(())
}

pub fn run_all() -> Result<(), Error> {
    console::log_1(&"todo: run all code blocks".into());

    Ok(())
}

fn on_run(_: MouseEvent) -> Result<(), Error> {
    console::log_1(&"todo: run code block".into());

    Ok(())
}

fn language_class(el: &HtmlElement) -> Option<String> {
    // TODO: Ideally we'd use an iterator, but that requires
    // https://github.com/rustwasm/wasm-bindgen/issues/1036 to be implemented.
    let class_list = el.class_list();
    for i in 0..class_list.length() {
        if let Some(class) = class_list.get(i) {
            if let Some(l) = class.strip_prefix(PREFIX) {
                return Some(l.to_string());
            }
        }
    }

    None
}
