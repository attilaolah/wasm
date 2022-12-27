use js_sys::{Array, Error, Function, Object, Reflect};
use wasm_bindgen::closure::Closure;
use wasm_bindgen::{JsCast, JsValue, throw};
use web_sys::{console, HtmlDivElement};

use crate::dom_helpers::{not_defined, window};

pub fn register_all() -> Result<(), Error> {
    register_mod_js()?;
    register_mod_html()?;
    register_mod_css()?;

    // TODO: JSON, YAML, CSV & fetch modules.

    Ok(())
}

pub fn mod_has(lang: &str) -> Result<bool, Error> {
    let mods: Object = mod_obj()?.dyn_into()?;
    Ok(mods.has_own_property(&lang.into()))
}

pub fn mod_run(out: &HtmlDivElement, src: &str, lang: &str) -> Result<JsValue, Error> {
    let module: Function = Reflect::get(&mod_obj()?, &lang.into())?.dyn_into()?;
    let args: Array = Array::new();
    match module.apply(&window()?.into(), &args) {
        Ok(val) => Ok(val),
        Err(err) => {
            Err(Error::new("problem calling module"))
        }
    }
}

fn register_mod_js() -> Result<(), Error> {
    let closure = Closure::wrap(Box::new(move |src| {
        console::log_1(&"todo: run js".into());
    }) as Box<dyn Fn(JsValue)>);
    Reflect::set(&mod_obj()?, &"js".into(), &closure.as_ref())?;
    closure.forget();

    Ok(())
}

fn register_mod_html() -> Result<(), Error> {
    let closure = Closure::wrap(Box::new(move |src| {
        console::log_1(&"todo: run html".into());
    }) as Box<dyn Fn(JsValue)>);
    Reflect::set(&mod_obj()?, &"html".into(), &closure.as_ref())?;
    closure.forget();

    Ok(())
}

fn register_mod_css() -> Result<(), Error> {
    let closure = Closure::wrap(Box::new(move |src| {
        console::log_1(&"todo: run css".into());
        throw("not implemented");
    }) as Box<dyn Fn(JsValue)>);
    Reflect::set(&mod_obj()?, &"css".into(), &closure.as_ref())?;
    closure.forget();

    Ok(())
}

fn mod_obj() -> Result<JsValue, Error> {
    const PROP: &str = "notebook";
    let nb = window()?.get(PROP).ok_or_else(not_defined(PROP))?;
    Ok(Reflect::get(&nb, &"mod".into())?)
}
