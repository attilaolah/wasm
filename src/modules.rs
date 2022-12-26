use js_sys::{Error, Object, Reflect};
use wasm_bindgen::closure::Closure;
use wasm_bindgen::{JsCast, JsValue};
use web_sys::console;

use crate::dom_helpers::{not_defined, throw, window};

const LANGS: [&str; 3] = ["html", "css", "js"];

pub fn register_all() -> Result<(), Error> {
    register_mod_js()?;
    register_mod_html()?;
    register_mod_css()?;

    Ok(())
}

pub fn has_mod(lang: &str) -> Result<bool, Error> {
    let mods: Object = mod_obj()?.dyn_into()?;
    Ok(mods.has_own_property(&lang.into()))
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
