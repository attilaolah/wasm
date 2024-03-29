use js_sys::{Array, Error, Function, Object, Promise, Reflect};
use wasm_bindgen::closure::Closure;
use wasm_bindgen::{JsCast, JsValue};
use web_sys::HtmlDivElement;

use crate::builtin_modules::{mod_css, mod_html, mod_js, mod_json, mod_yaml};
use crate::code_blocks::{get_lang, get_src};
use crate::dom::{not_defined, window};

pub fn register_all() -> Result<(), Error> {
    register(&mod_js, &["javascript", "js"])?;
    register(&mod_html, &["html"])?;
    register(&mod_css, &["css"])?;
    register(&mod_json, &["json"])?;
    register(&mod_yaml, &["yaml", "yml"])?;

    Ok(())
}

pub fn mod_has(lang: &str) -> Result<bool, Error> {
    let mods: Object = mod_obj()?.dyn_into()?;
    Ok(mods.has_own_property(&lang.into()))
}

pub fn mod_run(cell: &HtmlDivElement) -> Result<Promise, Error> {
    let code_src = get_src(&cell)?;
    let module: Function = Reflect::get(&mod_obj()?, &get_lang(&code_src)?.into())?.dyn_into()?;

    Ok(module
        .apply(&window()?.into(), &Array::of1(&cell.into()))?
        .dyn_into()?)
}

fn register(
    mod_fn: &'static dyn Fn(&HtmlDivElement) -> Result<Promise, Error>,
    langs: &[&str],
) -> Result<(), Error> {
    let run = Closure::wrap(Box::new(move |cell: &HtmlDivElement| mod_fn(cell))
        as Box<dyn Fn(&HtmlDivElement) -> Result<Promise, Error>>);
    for lang in langs {
        Reflect::set(&mod_obj()?, &JsValue::from_str(lang), &run.as_ref())?;
    }
    run.forget();

    Ok(())
}

fn mod_obj() -> Result<JsValue, Error> {
    const PROP: &str = "notebook";
    let nb = window()?.get(PROP).ok_or_else(not_defined(PROP))?;
    Ok(Reflect::get(&nb, &"mod".into())?)
}
