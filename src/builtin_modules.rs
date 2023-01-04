use js_sys::{Array, Error, Function, Object, Promise, Reflect, JSON};
use serde_json;
use serde_yaml;
use serde_yaml::value::Value;
use wasm_bindgen::closure::Closure;
use wasm_bindgen::{JsCast, JsValue};
use web_sys::{console, HtmlDivElement, HtmlElement, HtmlPreElement, HtmlStyleElement, Node};

use crate::code_blocks::{cell_err, get_cell, get_out, get_src, get_text};
use crate::dom::{create_element, document, throw, window};
use crate::prism;

const RES_PROP: &str = "nbres";

pub fn mod_js(cell: &HtmlDivElement) -> Result<Option<Promise>, Error> {
    let func = Function::new_no_args(&format!(
        "\
return (async (_) => {{
_ = _ ? await _ : _;
{}
}})({})",
        &get_text(&get_src(&cell)?)?,
        &mod_js_prev(&cell)?,
    ));
    let result = func.apply(&window()?.into(), &Array::new());

    set_res(
        &cell,
        match result {
            Err(ref val) => val,
            Ok(ref val) => val,
        },
    )?;

    if let Err(val) = result {
        // Early failure, caused by e.g. a syntax error.
        return Err(ensure_error(val));
    }

    // Capture only the ID to avoid moving the cell.
    // While only one of the two closures will be executed, we have no way of knowing which one.
    let id = cell_id(&cell)?;
    let resolve = Closure::wrap(Box::new(move |val| {
        if let Err(err) = mod_js_done(id, val, true) {
            console::error_1(&err);
        }
    }) as Box<dyn FnMut(JsValue)>);
    let reject = Closure::wrap(Box::new(move |val| {
        if let Err(err) = mod_js_done(id, val, false) {
            console::error_1(&err);
        }
    }) as Box<dyn FnMut(JsValue)>);
    let promise: Promise = result?.dyn_into()?;
    let then = promise.then2(&resolve, &reject);
    resolve.forget();
    reject.forget();

    Ok(Some(then))
}

fn mod_js_prev(cell: &HtmlDivElement) -> Result<String, Error> {
    match cell_id(&cell)? {
        0 => Ok("".to_string()),
        id => Ok(format!(
            "document?.getElementById('cell-{}')?.{}",
            id - 1,
            RES_PROP
        )),
    }
}

fn mod_js_done(cell_id: u32, val: JsValue, success: bool) -> Result<(), Error> {
    let cell: HtmlDivElement = get_cell(cell_id)?;
    let class_list = cell.class_list();
    class_list.remove_1("pending")?;

    if !success {
        console::log_1(&"call cell_err".into());
        return cell_err(&cell, ensure_error(val));
    }

    class_list.add_1("ok")?;
    if val.is_undefined() {
        return Ok(()); // no return value
    }

    let out = get_out(&cell)?;
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
            .unwrap_or("failed to json-encode value".to_string()),
    );

    pre.append_child(&code)?;
    out.append_child(&pre)?;

    prism::highlight_all_under(&out)?;

    Ok(())
}

pub fn mod_html(cell: &HtmlDivElement) -> Result<Option<Promise>, Error> {
    let out = get_out(&cell)?;

    out.set_inner_html(&get_text(&get_src(&cell)?)?);
    if let Some(result) = out.last_element_child() {
        set_res(&cell, &result)?;
    }

    Ok(None)
}

pub fn mod_css(cell: &HtmlDivElement) -> Result<Option<Promise>, Error> {
    let out = get_out(&cell)?;
    let style: HtmlStyleElement = create_element("style")?;

    style.set_inner_html(&get_text(&get_src(&cell)?)?);
    out.class_list().add_1("hidden")?;
    out.append_child(&style)?;

    let style_sheets = document()?.style_sheets();
    for i in 0..style_sheets.length() {
        if let Some(style_sheet) = style_sheets.get(i) {
            if style.is_same_node(style_sheet.owner_node().as_ref()) {
                set_res(&cell, &style_sheet)?;
                break;
            }
        }
    }

    Ok(None)
}

pub fn mod_json(cell: &HtmlDivElement) -> Result<Option<Promise>, Error> {
    set_res(&cell, &JSON::parse(&get_text(&get_src(&cell)?)?)?)?;

    Ok(None)
}

pub fn mod_yaml(cell: &HtmlDivElement) -> Result<Option<Promise>, Error> {
    let yaml: Value = serde_yaml::from_str(&get_text(&get_src(&cell)?)?)
        .or_else(|err| Err(Error::new(&format!("failed to parse yaml: {}", err))))?;
    let json: String = serde_json::to_string(&yaml)
        .or_else(|err| Err(Error::new(&format!("failed tore-encode to json: {}", err))))?;

    set_res(&cell, &JSON::parse(&json)?)?;

    Ok(None)
}

fn set_res(cell: &HtmlDivElement, res: &JsValue) -> Result<bool, Error> {
    Ok(Reflect::set(&cell, &RES_PROP.into(), &res)?)
}

fn cell_id(cell: &HtmlDivElement) -> Result<u32, Error> {
    cell.dataset()
        .get("id")
        .ok_or_else(throw("missing cell id"))?
        .parse()
        .or_else(|err| Err(Error::new(&format!("malformed cell id: {}", err))))
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
