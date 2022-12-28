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
            console::error_1(&val);
            let pre: HtmlPreElement = create_element("pre")?;
            out.append_child(&pre)?;

            // TODO: Try to just pass the error as-is to pre.set_inner_text().
            // If that doesn't work, try to reflect-execute the toString method.

            // Ideally only errors would be thrown.
            if val.has_type::<Error>() {
                let err: Error = val.dyn_into()?;
                pre.set_inner_text(&err.to_string().as_string().unwrap_or("".to_string()));
                return Err(err);
            }

            // But throwing any object is supported.
            if val.has_type::<Object>() {
                let obj: Object = val.dyn_into()?;
                let text: String = obj
                    .to_string()
                    .as_string()
                    .unwrap_or("unknown error".to_string());
                pre.set_inner_text(&text);
                return Err(Error::new(&text));
            }

            // String is the only basic type that is supported.
            if val.is_string() {
                if let Some(text) = val.as_string() {
                    pre.set_inner_text(&text);
                    return Err(Error::new(&text));
                }
            }

            const ERR_TEXT: &str = "caught value is not an error type";
            console::warn_1(&"HINT: Only throw instances of Error or a subclass, e.g. `throw new Error('reason');`.".into());
            pre.set_inner_text(&ERR_TEXT);
            Err(Error::new(&ERR_TEXT))
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
