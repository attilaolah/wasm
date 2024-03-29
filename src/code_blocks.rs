use js_sys::{Error, Object, Promise, Reflect};
use wasm_bindgen::closure::Closure;
use wasm_bindgen::{JsCast, JsValue};
use web_sys::{
    console, Event, EventInit, HtmlDivElement, HtmlElement, HtmlPreElement, HtmlTemplateElement,
    Node,
};

use crate::builtin_modules::{cell_id, ensure_error};
use crate::dom::{
    clear_children, create_element, document, get_element, not_defined, not_found, on_el_evt,
    query_element, throw, window, wrong_type, EVT_CLICK,
};
use crate::modules::{mod_has, mod_run};

const CODE_BLOCK_HTML: &str = include_str!(env!("CODE_BLOCK_HTML"));

const CELL_ID_PREFIX: &str = "cell-";
const LANGUAGE_PREFIX: &str = "language-";

const EVT_RUN: &str = "run";
const EVT_CLEAR: &str = "clear";

const RES_PROP: &str = "nbres";

pub fn prepare_all() -> Result<(), Error> {
    let codes = document()?.query_selector_all("main>pre>code")?;
    for i in 0..codes.length() {
        if let Some(node) = codes.get(i) {
            prepare_block(
                &node.dyn_into().or_else(wrong_type("query_selector_all"))?,
                i,
            )?;
        }
    }

    Ok(())
}

pub fn run_all() -> Result<(), Error> {
    let cells = document()?.query_selector_all(":not(.ro).cell")?;
    for i in 0..cells.length() {
        if let Some(node) = cells.get(i) {
            node.dispatch_event(&Event::new(EVT_RUN)?)?;
        }
    }

    Ok(())
}

pub fn get_src(cell: &HtmlDivElement) -> Result<HtmlElement, Error> {
    query_element(cell, ".src-code")
}

pub fn get_cell(id: u32) -> Result<HtmlDivElement, Error> {
    get_element(&format!("{}{}", CELL_ID_PREFIX, id))
}

pub fn get_out(cell: &HtmlDivElement) -> Result<HtmlElement, Error> {
    query_element(cell, "div.out")
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
    let tpl: HtmlTemplateElement = create_element("template")?;
    tpl.set_inner_html(CODE_BLOCK_HTML);

    let cell: HtmlDivElement = tpl
        .content()
        .children()
        .item(0)
        .ok_or_else(throw("template contains no elements"))?
        .dyn_into()
        .or_else(wrong_type("item"))?;
    cell.dataset().set("id", &id.to_string())?;
    cell.set_id(&format!("{}{}", CELL_ID_PREFIX, id));
    on_el_evt(EVT_RUN, &cell, &on_cell_run)?;
    on_el_evt(EVT_CLEAR, &cell, &on_cell_clear)?;
    on_el_evt(
        EVT_CLICK,
        &query_element(&cell, ".controls .copy")?,
        &on_copy_click,
    )?;

    let pre: HtmlPreElement = code
        .parent_element()
        .ok_or_else(not_defined("parent_element"))?
        .dyn_into()
        .or_else(wrong_type("parent_element"))?;

    pre.parent_element()
        .ok_or_else(not_defined("parent_element"))?
        .insert_before(&tpl.content(), Some(&pre))?;
    query_element(&cell, ".src")?.append_child(&pre)?;
    code.class_list().add_1("src-code")?;

    let tag = language_class(&code);
    let class_list = cell.class_list();

    if let Some(lang) = tag {
        query_element(&cell, ".controls .tag")?.set_inner_text(&lang.to_uppercase());
        if !mod_has(&lang)? {
            class_list.add_1("ro")?;
            return Ok(());
        }
    } else {
        class_list.add_2("ro", "no-tag")?;
        return Ok(());
    }

    on_el_evt(
        EVT_CLICK,
        &query_element(&cell, ".controls .run")?,
        &on_run_click,
    )?;
    on_el_evt(
        EVT_CLICK,
        &query_element(&cell, ".controls .clear")?,
        &on_clear_click,
    )?;

    Ok(())
}

fn on_run_click(evt: Event) -> Result<(), Error> {
    bubble_up(evt, EVT_RUN)
}

fn on_clear_click(evt: Event) -> Result<(), Error> {
    bubble_up(evt, EVT_CLEAR)
}

fn on_copy_click(evt: Event) -> Result<(), Error> {
    if let Some(cb) = window()?.navigator().clipboard() {
        // Fire & forget promise.
        // TODO: Add a 'Copied!' tooltip whin resolving!
        _ = cb.write_text(&get_text(&get_src(&current_cell(&evt)?)?)?);
    }

    Ok(())
}

fn on_cell_run(evt: Event) -> Result<(), Error> {
    let cell: HtmlDivElement = current_cell(&evt)?;
    let class_list = cell.class_list();
    let out = get_out(&cell)?;

    class_list.add_1("run")?;
    class_list.remove_3("ok", "pending", "err")?;
    clear_children(&out)?;

    match mod_run(&cell) {
        Ok(val) => cell_pending(&cell, val)?,
        Err(err) => cell_err(&cell, err.into())?,
    };

    evt.stop_propagation();
    Ok(())
}

fn on_cell_clear(evt: Event) -> Result<(), Error> {
    let cell: HtmlDivElement = current_cell(&evt)?;
    let class_list = cell.class_list();
    let out = get_out(&cell)?;

    class_list.remove_4("run", "ok", "pending", "err")?;
    clear_children(&out)?;
    del_res(&cell)?;

    evt.stop_propagation();
    Ok(())
}

fn cell_status(cell: &HtmlDivElement, status: &str) -> Result<(), Error> {
    let class_list = cell.class_list();
    class_list.remove_3("ok", "pending", "err")?;
    class_list.add_1(status)?;

    Ok(())
}

fn cell_ok(cell: &HtmlDivElement, val: JsValue) -> Result<(), Error> {
    cell_set_type(&cell, &type_name(&val.clone().into()))?;
    cell_status(&cell, "ok")?;
    set_res(&cell, &val)?;

    let out = get_out(&cell)?;
    if val.has_type::<Node>() {
        let node: Node = val.dyn_into()?;
        out.append_child(&node)?;
    }

    Ok(())
}

fn cell_pending(cell: &HtmlDivElement, promise: Promise) -> Result<(), Error> {
    cell_set_type(&cell, &type_name(&promise))?;
    cell_status(&cell, "pending")?;
    set_res(&cell, &promise)?;

    // Capture only the ID to avoid moving the cell.
    // While only one of the two closures will be executed, we have no way of knowing which one.
    let id = cell_id(&cell)?;
    let resolve = Closure::wrap(Box::new(move |val| match get_cell(id) {
        Ok(cell) => {
            if let Err(err) = cell_ok(&cell, val) {
                console::error_1(&err);
            }
        }
        Err(err) => {
            console::error_1(&err);
        }
    }) as Box<dyn FnMut(JsValue)>);
    let reject = Closure::wrap(Box::new(move |val| match get_cell(id) {
        Ok(cell) => {
            if let Err(err) = cell_err(&cell, ensure_error(val)) {
                console::error_1(&err);
            }
        }
        Err(err) => {
            console::error_1(&err);
        }
    }) as Box<dyn FnMut(JsValue)>);
    _ = promise.then2(&resolve, &reject);
    resolve.forget();
    reject.forget();

    Ok(())
}

fn cell_err(cell: &HtmlDivElement, err: Error) -> Result<(), Error> {
    cell_set_type(&cell, &type_name(&err))?;
    cell_status(&cell, "err")?;

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

fn cell_set_type(cell: &HtmlDivElement, typ: &str) -> Result<(), Error> {
    query_element(&cell, ".return-type")?.set_inner_text(typ);

    Ok(())
}

fn bubble_up(evt: Event, new: &str) -> Result<(), Error> {
    current_target(&evt)?.dispatch_event(&Event::new_with_event_init_dict(
        new,
        EventInit::new().bubbles(true),
    )?)?;

    Ok(())
}

fn current_cell(evt: &Event) -> Result<HtmlDivElement, Error> {
    Ok(current_target(&evt)?
        .closest(".cell")?
        .ok_or_else(not_found(".cell"))?
        .dyn_into()
        .or_else(wrong_type("closest"))?)
}

fn current_target(evt: &Event) -> Result<HtmlElement, Error> {
    Ok(evt
        .current_target()
        .ok_or_else(not_defined("current_target"))?
        .dyn_into()
        .or_else(wrong_type("current_target"))?)
}

fn type_name(obj: &Object) -> String {
    if obj.is_null() {
        return "N/A (null)".to_string();
    }
    if obj.is_undefined() {
        return "N/A (undefined)".to_string();
    }
    let no_ctor = obj.constructor().is_undefined();
    let type_name = if no_ctor {
        "Object".to_string()
    } else {
        obj.constructor()
            .name()
            .as_string()
            .unwrap_or("?".to_string())
    };
    let suffixes: Vec<String> = vec![
        if no_ctor {
            Some("no constructor")
        } else {
            None
        },
        if Object::is_sealed(&obj) {
            Some("sealed")
        } else {
            None
        },
        if Object::is_frozen(&obj) {
            Some("frozen")
        } else {
            None
        },
    ]
    .into_iter()
    .filter_map(|s| s)
    .map(|s| s.to_string())
    .collect();
    if suffixes.is_empty() {
        type_name
    } else {
        format!("{} ({})", type_name, suffixes.join(", "))
    }
    .to_string()
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

pub fn get_res(cell: &HtmlDivElement) -> Result<String, Error> {
    match cell_id(&cell)? {
        0 => Ok("".to_string()),
        id => Ok(format!(
            "document?.getElementById('cell-{}')?.{}",
            id - 1,
            RES_PROP
        )),
    }
}

fn set_res(cell: &HtmlDivElement, res: &JsValue) -> Result<bool, Error> {
    Ok(Reflect::set(&cell, &RES_PROP.into(), &res)?)
}

fn del_res(cell: &HtmlDivElement) -> Result<bool, Error> {
    Ok(Reflect::delete_property(&cell, &RES_PROP.into())?)
}
