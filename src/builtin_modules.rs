use js_sys::Error;
use web_sys::{console, HtmlDivElement};

use crate::code_blocks::{get_out, get_src, get_text, set_res};

pub fn mod_js(_cell: &HtmlDivElement) -> Result<(), Error> {
    console::log_1(&"todo: run js".into());

    Ok(())
}

pub fn mod_html(cell: &HtmlDivElement) -> Result<(), Error> {
    let code_src = get_src(&cell)?;
    let raw_html = get_text(&code_src)?;
    let out = get_out(&cell)?;
    out.set_inner_html(&raw_html);

    if let Some(result) = out.last_element_child() {
        set_res(&cell, &result)?;
    }

    Ok(())
}

pub fn mod_css(_cell: &HtmlDivElement) -> Result<(), Error> {
    console::log_1(&"todo: run css".into());

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
