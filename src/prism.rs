use js_sys::{Array, Error, Function, Object, Reflect};
use wasm_bindgen::JsCast;
use web_sys::HtmlElement;

use crate::dom::{not_defined, window};

const PRISM: &str = "Prism";

pub fn highlight_all_under(root: &HtmlElement) -> Result<(), Error> {
    let prism: Object = window()?.get(PRISM).ok_or_else(not_defined(PRISM))?;
    let method: Function = Reflect::get(&prism, &"highlightAllUnder".into())?.dyn_into()?;
    Reflect::apply(&method, &prism, &Array::of1(root))?;

    Ok(())
}
