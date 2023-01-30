use js_sys::{Array, Error, Function, Object, Promise, JSON};
use serde_json;
use serde_yaml;
use serde_yaml::value::Value;
use wasm_bindgen::closure::Closure;
use wasm_bindgen::{JsCast, JsValue};
use web_sys::{console, HtmlDivElement, HtmlElement, HtmlPreElement, HtmlStyleElement, Node};

use crate::code_blocks::{get_cell, get_out, get_res, get_src, get_text};
use crate::dom::{create_element, document, throw, window};
use crate::prism;

pub fn mod_js(cell: &HtmlDivElement) -> Result<Promise, Error> {
    let func = Function::new_no_args(&format!(
        "\
return (async (_) => {{
_ = _ ? await _ : _;
{}
}})({})",
        &get_text(&get_src(&cell)?)?,
        &get_res(&cell)?,
    ));
    let result = func.apply(&window()?.into(), &Array::new());

    if let Err(val) = result {
        // Early failure, caused by e.g. a syntax error.
        return Err(ensure_error(val));
    }

    // Capture only the ID to avoid moving the cell.
    // While only one of the two closures will be executed, we have no way of knowing which one.
    let id = cell_id(&cell)?;
    let promise: Promise = result?.dyn_into()?;

    Ok(Promise::new(&mut |resolve, reject| {
        let ok_cb = mod_js_then(resolve, id);
        let err_cb = Closure::wrap(Box::new(move |val| {
            if let Err(err) = reject.call1(&JsValue::NULL, &val) {
                console::error_1(&err);
            }
        }) as Box<dyn FnMut(JsValue)>);
        _ = promise.then2(&ok_cb, &err_cb);
        err_cb.forget();
        ok_cb.forget();
    }))
}

fn mod_js_then(cb: Function, id: u32) -> Closure<(dyn FnMut(JsValue) + 'static)> {
    Closure::wrap(Box::new(move |val| {
        if let Err(err) = mod_js_done(id, val).and_then(|val| Ok(cb.call1(&JsValue::NULL, &val))) {
            console::error_1(&err);
        }
    }) as Box<dyn FnMut(JsValue)>)
}

fn mod_js_done(cell_id: u32, val: JsValue) -> Result<JsValue, Error> {
    if val.is_undefined() || val.has_type::<Node>() {
        return Ok(val);
    }

    let out = get_out(&get_cell(cell_id)?)?;
    let pre: HtmlPreElement = create_element("pre")?;
    let code: HtmlElement = create_element("code")?;

    pre.set_class_name("language-json");
    code.set_inner_html(
        &JSON::stringify_with_replacer_and_space(&val, &JsValue::NULL, &2.into())?
            .as_string()
            .unwrap_or("failed to json-encode value".to_string()),
    );

    pre.append_child(&code)?;
    out.append_child(&pre)?;

    prism::highlight_all_under(&out)?;

    Ok(val)
}

pub fn mod_html(cell: &HtmlDivElement) -> Result<Promise, Error> {
    let out = get_out(&cell)?;
    out.set_inner_html(&get_text(&get_src(&cell)?)?);

    Ok(Promise::resolve(&out.child_nodes()))
}

pub fn mod_css(cell: &HtmlDivElement) -> Result<Promise, Error> {
    let out = get_out(&cell)?;
    let style: HtmlStyleElement = create_element("style")?;

    style.set_inner_html(&get_text(&get_src(&cell)?)?);
    out.class_list().add_1("hidden")?;
    out.append_child(&style)?;

    let style_sheets = document()?.style_sheets();
    for i in 0..style_sheets.length() {
        if let Some(style_sheet) = style_sheets.get(i) {
            if style.is_same_node(style_sheet.owner_node().as_ref()) {
                return Ok(Promise::resolve(&style_sheet));
            }
        }
    }

    // This should never happen.
    Err(Error::new("style sheet not found"))
}

pub fn mod_json(cell: &HtmlDivElement) -> Result<Promise, Error> {
    Ok(Promise::resolve(&JSON::parse(&get_text(&get_src(
        &cell,
    )?)?)?))
}

pub fn mod_yaml(cell: &HtmlDivElement) -> Result<Promise, Error> {
    let yaml: Value = serde_yaml::from_str(&get_text(&get_src(&cell)?)?)
        .or_else(|err| Err(Error::new(&format!("failed to parse yaml: {}", err))))?;
    let json: String = serde_json::to_string(&yaml)
        .or_else(|err| Err(Error::new(&format!("failed to re-encode to json: {}", err))))?;

    Ok(Promise::resolve(&JSON::parse(&json)?))
}

pub fn cell_id(cell: &HtmlDivElement) -> Result<u32, Error> {
    cell.dataset()
        .get("id")
        .ok_or_else(throw("missing cell id"))?
        .parse()
        .or_else(|err| Err(Error::new(&format!("malformed cell id: {}", err))))
}

pub fn ensure_error(val: JsValue) -> Error {
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
