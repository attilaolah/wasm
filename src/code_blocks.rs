use js_sys::{Error, Reflect};
use wasm_bindgen::{JsCast, JsValue};
use web_sys::{
    console, HtmlButtonElement, HtmlDivElement, HtmlElement, HtmlPreElement, MouseEvent,
};

use crate::dom_helpers::{create_element, document, not_defined, on_el_click, throw, wrong_type};
use crate::modules::{mod_has, mod_run};

const SRC: &str = "src";
const OUT: &str = "out";
const PREFIX: &str = "language-";

const RES_VAR: &str = "_";

pub fn prepare_all() -> Result<(), Error> {
    // TODO: Ideally we'd use an iterator, but that requires
    // https://github.com/rustwasm/wasm-bindgen/issues/1036 to be implemented.
    let codes = document()?.query_selector_all(&format!("pre>code[class^={}]", PREFIX))?;
    for i in 0..codes.length() {
        if let Some(node) = codes.get(i) {
            let el: HtmlElement = node.dyn_into().or_else(wrong_type("query_selector_all"))?;
            prepare_block(&el, i)?;
        }
    }

    Ok(())
}

pub fn run_all() -> Result<(), Error> {
    console::log_1(&"todo: run all code blocks".into());

    Ok(())
}

pub fn get_src(cell: &HtmlDivElement) -> Result<HtmlElement, Error> {
    cell.query_selector("code.src")?
        .ok_or_else(throw("code block not found"))?
        .dyn_into()
        .or_else(wrong_type("query_selector"))
}

pub fn get_out(cell: &HtmlDivElement) -> Result<HtmlDivElement, Error> {
    cell.query_selector("div.out")?
        .ok_or_else(throw("output div not found"))?
        .dyn_into()
        .or_else(wrong_type("query_selector"))
}

pub fn get_text(src: &HtmlElement) -> Result<String, Error> {
    src.text_content()
        .ok_or_else(throw("code block contains no text"))
}

pub fn get_lang(src: &HtmlElement) -> Result<String, Error> {
    language_class(&src).ok_or_else(throw("language class not found"))
}

pub fn set_res(cell: &HtmlDivElement, res: &JsValue) -> Result<bool, Error> {
    let ok = Reflect::set(&cell, &RES_VAR.into(), &res)?;

    Ok(ok)
}

// Prepares a single code block for execution.
fn prepare_block(code: &HtmlElement, id: u32) -> Result<(), Error> {
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

    let lang = &language_class(&code).unwrap_or("".to_string());
    if !mod_has(&lang)? {
        return Ok(());
    }

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

fn on_run(evt: MouseEvent) -> Result<(), Error> {
    let target: HtmlButtonElement = evt
        .current_target()
        .ok_or_else(not_defined("current_target"))?
        .dyn_into()
        .or_else(wrong_type("current_target"))?;
    let cell: HtmlDivElement = target
        .closest("div.cell")?
        .ok_or_else(throw("cell not found"))?
        .dyn_into()
        .or_else(wrong_type("closest"))?;

    run_cell(&cell)
}

fn run_cell(cell: &HtmlDivElement) -> Result<(), Error> {
    let res = mod_run(&cell);
    let class_list = cell.class_list();
    class_list.toggle_with_force("run-ok", res.is_ok())?;
    class_list.toggle_with_force("run-err", res.is_err())?;

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
