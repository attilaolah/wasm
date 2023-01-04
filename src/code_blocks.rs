use js_sys::Error;
use wasm_bindgen::JsCast;
use web_sys::{
    console, Event, EventInit, HtmlButtonElement, HtmlDivElement, HtmlElement, HtmlPreElement,
};

use crate::dom::{
    clear_children, create_element, document, get_element, not_defined, on_el_evt, throw,
    wrong_type, EVT_CLICK,
};
use crate::modules::{mod_has, mod_run};

const SRC: &str = "src";
const OUT: &str = "out";
const CELL: &str = "cell";
const CELL_ID_PREFIX: &str = "cell-";
const LANGUAGE_PREFIX: &str = "language-";
const EVT_RUN: &str = "run";

pub fn prepare_all() -> Result<(), Error> {
    let codes = document()?.query_selector_all(&format!("pre>code[class^={}]", LANGUAGE_PREFIX))?;
    for i in 0..codes.length() {
        if let Some(node) = codes.get(i) {
            let el: HtmlElement = node.dyn_into().or_else(wrong_type("query_selector_all"))?;
            prepare_block(&el, i)?;
        }
    }

    Ok(())
}

pub fn run_all() -> Result<(), Error> {
    let cells = document()?.get_elements_by_class_name(CELL);
    for i in 0..cells.length() {
        if let Some(el) = cells.get_with_index(i) {
            el.dispatch_event(&Event::new(EVT_RUN)?)?;
        }
    }

    Ok(())
}

pub fn get_src(cell: &HtmlDivElement) -> Result<HtmlElement, Error> {
    cell.query_selector("code.src")?
        .ok_or_else(throw("code block not found"))?
        .dyn_into()
        .or_else(wrong_type("query_selector"))
}

pub fn get_cell(id: u32) -> Result<HtmlDivElement, Error> {
    get_element(&format!("{}{}", CELL_ID_PREFIX, id))
}

pub fn get_out(cell: &HtmlDivElement) -> Result<HtmlDivElement, Error> {
    cell.query_selector("div.out")?
        .ok_or_else(throw("output div not found"))?
        .dyn_into()
        .or_else(wrong_type("query_selector"))
}

pub fn get_text(src: &HtmlElement) -> Result<String, Error> {
    Ok(src
        .text_content()
        .ok_or_else(throw("code block contains no text"))?
        .trim()
        .to_string())
}

pub fn get_lang(src: &HtmlElement) -> Result<String, Error> {
    language_class(&src).ok_or_else(throw("language class not found"))
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
    cell.set_class_name(CELL);
    cell.dataset().set("id", &id.to_string())?;
    cell.set_id(&format!("{}{}", CELL_ID_PREFIX, id));
    on_el_evt(EVT_RUN, &cell, &on_cell_run)?;

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
    on_el_evt(EVT_CLICK, &run, &on_run_click)?;

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

fn on_run_click(evt: Event) -> Result<(), Error> {
    evt.current_target()
        .ok_or_else(not_defined("current_target"))?
        .dispatch_event(&Event::new_with_event_init_dict(
            EVT_RUN,
            EventInit::new().bubbles(true),
        )?)?;

    Ok(())
}

fn on_cell_run(evt: Event) -> Result<(), Error> {
    let cell: HtmlDivElement = evt
        .current_target()
        .ok_or_else(not_defined("current_target"))?
        .dyn_into()
        .or_else(wrong_type("current_target"))?;
    let class_list = cell.class_list();
    let out = get_out(&cell)?;

    class_list.add_1("run")?;
    class_list.remove_3("ok", "pending", "err")?;
    clear_children(&out)?;

    match mod_run(&cell) {
        Ok(None) => class_list.add_1("ok")?,
        Ok(Some(_)) => class_list.add_1("pending")?,
        Err(err) => cell_err(&cell, err.into())?,
    };

    evt.stop_propagation();
    Ok(())
}

pub fn cell_err(cell: &HtmlDivElement, err: Error) -> Result<(), Error> {
    cell.class_list().add_1("err")?;
    let pre: HtmlPreElement = create_element("pre")?;

    let mut has_content = false;
    if let Some(text) = err.name().as_string() {
        let strong: HtmlElement = create_element("strong")?;
        strong.append_with_str_2(&text, ":")?;
        pre.append_child(&strong)?;
        has_content = true;
    }
    if let Some(text) = err.message().as_string() {
        pre.append_with_str_2(" ", &text)?;
        has_content = true;
    }
    if has_content {
        get_out(&cell)?.append_child(&pre)?;
    }

    // Log stack trace information to the console.
    console::error_1(&err);

    Ok(())
}

fn language_class(el: &HtmlElement) -> Option<String> {
    let class_list = el.class_list();
    (0..class_list.length()).find_map(|i| {
        Some(
            class_list
                .get(i)?
                .strip_prefix(LANGUAGE_PREFIX)?
                .to_string(),
        )
    })
}
