use js_sys::{eval, Error, Object, JSON};
use wasm_bindgen::{JsCast, JsValue};
use web_sys::{console, HtmlDivElement, HtmlElement, HtmlPreElement, HtmlStyleElement, Node};

use crate::code_blocks::{get_out, get_src, get_text, set_res};
use crate::dom::{clear_children, create_element, document};
use crate::prism;

pub fn mod_js(cell: &HtmlDivElement) -> Result<(), Error> {
    let out = get_out(&cell)?;
    let result = eval(&get_text(&get_src(&cell)?)?);
    let result_val: &JsValue = match result {
        Err(ref val) => val,
        Ok(ref val) => val,
    };

    clear_children(&out)?;
    set_res(&cell, result_val)?;

    if result_val.is_undefined() {
        result?; // Just extract the error, no output.
        return Ok(()); // Success but no return value.
    }

    match result {
        Err(val) => Err(mod_js_err(&out, val)?),
        Ok(val) => Ok(mod_js_ok(&out, val)?),
    }
}

fn mod_js_err(out: &HtmlDivElement, val: JsValue) -> Result<Error, Error> {
    let err = ensure_error(val);
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
        out.append_child(&pre)?;
    }

    // Log stack trace information to the console.
    console::error_1(&err);

    Ok(err)
}

fn mod_js_ok(out: &HtmlDivElement, val: JsValue) -> Result<(), Error> {
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

    prism::highlight_all_under(&out)?;

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

fn ensure_error(val: JsValue) -> Error {
    if val.has_type::<Error>() {
        val.into()
    } else {
        let object: Object = val.into();
        let message = object
            .to_string()
            .as_string()
            .unwrap_or("unknown error".to_string());
        Error::new(&message)
    }
}
