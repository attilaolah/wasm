use js_sys::{eval, Error, Object, Reflect, JSON};
use serde_json;
use serde_yaml;
use serde_yaml::value::Value;
use wasm_bindgen::{JsCast, JsValue};
use web_sys::{console, HtmlDivElement, HtmlElement, HtmlPreElement, HtmlStyleElement, Node};

use crate::code_blocks::{get_out, get_src, get_text};
use crate::dom::{create_element, document, throw};
use crate::prism;

const RES_PROP: &str = "nbres";

pub fn mod_js(cell: &HtmlDivElement) -> Result<(), Error> {
    let out = get_out(&cell)?;
    let result = eval(&format!(
        "{}{}",
        &mod_js_prefix(&cell)?,
        &get_text(&get_src(&cell)?)?
    ));

    set_res(
        &cell,
        match result {
            Err(ref val) => val,
            Ok(ref val) => val,
        },
    )?;

    if let Err(val) = result {
        return Err(ensure_error(val));
    }

    let val = result?;
    if val.is_undefined() {
        return Ok(()); // No return value.
    }
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

fn mod_js_prefix(cell: &HtmlDivElement) -> Result<String, Error> {
    let id: i32 = cell
        .dataset()
        .get("id")
        .ok_or_else(throw("missing cell id"))?
        .parse()
        .or_else(|err| Err(Error::new(&format!("malformed cell id: {}", err))))?;
    match id {
        0 => Ok("".to_string()),
        _ => Ok(format!(
            "const _ = document?.getElementById('cell-{}')?.{};\n",
            id - 1,
            RES_PROP
        )),
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

    Ok(())
}

pub fn mod_json(cell: &HtmlDivElement) -> Result<(), Error> {
    set_res(&cell, &JSON::parse(&get_text(&get_src(&cell)?)?)?)?;

    Ok(())
}

pub fn mod_yaml(cell: &HtmlDivElement) -> Result<(), Error> {
    let yaml: Value = serde_yaml::from_str(&get_text(&get_src(&cell)?)?)
        .or_else(|err| Err(Error::new(&format!("failed to parse yaml: {}", err))))?;
    let json: String = serde_json::to_string(&yaml)
        .or_else(|err| Err(Error::new(&format!("failed tore-encode to json: {}", err))))?;

    set_res(&cell, &JSON::parse(&json)?)?;

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

fn set_res(cell: &HtmlDivElement, res: &JsValue) -> Result<bool, Error> {
    Ok(Reflect::set(&cell, &RES_PROP.into(), &res)?)
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
