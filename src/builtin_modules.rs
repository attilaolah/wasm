use js_sys::{eval, Error};
use wasm_bindgen::JsCast;
use web_sys::{console, HtmlDivElement, HtmlPreElement, HtmlStyleElement};

use crate::code_blocks::{get_out, get_src, get_text, set_res};
use crate::dom_helpers::{clear_children, create_element, document};

pub fn mod_js(cell: &HtmlDivElement) -> Result<(), Error> {
    let out = get_out(&cell)?;

    match eval(&get_text(&get_src(&cell)?)?) {
        Ok(val) => {
            set_res(&cell, &val)?;
            Ok(())
        }
        Err(val) => {
            let err: Error = val.dyn_into()?;
            let pre: HtmlPreElement = create_element("pre")?;
            pre.set_inner_text(&err.to_string().as_string().unwrap_or("".to_string()));

            clear_children(&out)?;
            out.append_child(&pre)?;

            set_res(&cell, &err)?;
            Err(err)
        }
    }
}

pub fn mod_html(cell: &HtmlDivElement) -> Result<(), Error> {
    let out = get_out(&cell)?;

    out.set_inner_html(&get_text(&get_src(&cell)?)?);
    if let Some(result) = out.last_element_child() {
        set_res(&cell, &result)?;
    }

    Ok(())
}

pub fn mod_css(cell: &HtmlDivElement) -> Result<(), Error> {
    let out = get_out(&cell)?;
    let style: HtmlStyleElement = create_element("style")?;

    style.set_inner_html(&get_text(&get_src(&cell)?)?);
    out.set_inner_html(&style.outer_html());

    // TODO: Ideally we'd use an iterator, but that requires
    // https://github.com/rustwasm/wasm-bindgen/issues/1036 to be implemented.
    let style_sheets = document()?.style_sheets();
    for i in 0..style_sheets.length() {
        if let Some(style_sheet) = style_sheets.get(i) {
            if style.is_same_node(style_sheet.owner_node().as_ref()) {
                set_res(&cell, &style_sheet)?;
                break;
            }
        }
    }

    Ok(())
}

pub fn mod_json(_cell: &HtmlDivElement) -> Result<(), Error> {
    console::log_1(&"todo: run json".into());

    Ok(())
}

pub fn mod_yaml(_cell: &HtmlDivElement) -> Result<(), Error> {
    console::log_1(&"todo: run yaml".into());

    Ok(())
}

pub fn mod_csv(_cell: &HtmlDivElement) -> Result<(), Error> {
    console::log_1(&"todo: run csv".into());

    Ok(())
}

pub fn mod_fetch(_cell: &HtmlDivElement) -> Result<(), Error> {
    console::log_1(&"todo: run fetch".into());

    Ok(())
}
