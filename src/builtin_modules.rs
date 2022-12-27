use js_sys::Error;
use web_sys::{console, HtmlDivElement, HtmlStyleElement};

use crate::code_blocks::{get_out, get_src, get_text, set_res};
use crate::dom_helpers::{document, create_element};

pub fn mod_js(_cell: &HtmlDivElement) -> Result<(), Error> {
    console::log_1(&"todo: run js".into());

    Ok(())
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
