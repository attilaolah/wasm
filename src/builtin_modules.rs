use js_sys::{eval, Error, Object, JSON};
use wasm_bindgen::{JsCast, JsValue};
use web_sys::{console, HtmlDivElement, HtmlElement, HtmlPreElement, HtmlStyleElement, Node};

use crate::code_blocks::{get_out, get_src, get_text, set_res};
use crate::dom_helpers::{clear_children, create_element, document};

pub fn mod_js(cell: &HtmlDivElement) -> Result<(), Error> {
    let out = get_out(&cell)?;
    let result = eval(&get_text(&get_src(&cell)?)?);
    let result_val: &JsValue = match result {
        Ok(ref val) => val,
        Err(ref val) => val,
    };

    clear_children(&out)?;
    set_res(&cell, result_val)?;

    if result_val.is_undefined() {
        result?; // Just extract the error, no output.
        return Ok(()); // Success but no return value.
    }

    match result {
        Err(val) => {
            let err: Error;
            let text: String = if val.has_type::<Error>() {
                // Ideally the exception that was thrown is an error.
                err = val.into();
                err.to_string()
                    .as_string()
                    .unwrap_or("unknown error".to_string())
            } else {
                // If the exception is not an error, create one using the value's to_string().
                let obj: Object = val.into();
                let text = obj
                    .to_string()
                    .as_string()
                    .unwrap_or("unknown error".to_string());
                err = Error::new(&text);
                text
            };
            let pre: HtmlPreElement = create_element("pre")?;

            // Log stack trace information to the console.
            console::error_1(&err);

            pre.set_inner_text(&text);
            out.append_child(&pre)?;
            Err(err)
        }
        Ok(val) => {
            if val.has_type::<Node>() {
                let node: Node = val.dyn_into()?;
                out.append_child(&node)?;
                return Ok(());
            }

            let pre: HtmlPreElement = create_element("pre")?;
            pre.set_class_name("language-json");

            let code: HtmlElement = create_element("code")?;
            code.set_inner_html(
                &JSON::stringify_with_replacer_and_space(&val, &JsValue::NULL, &2.into())?
                    .as_string()
                    .unwrap_or("could not json-encode value".to_string()),
            );

            pre.append_child(&code)?;
            out.append_child(&pre)?;

            // TODO: prism_highlight_all_under(pre);

            Ok(())
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
    out.class_list().add_1("hidden")?;

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
