use js_sys::Error;
use wasm_bindgen::closure::Closure;
use wasm_bindgen::JsCast;
use web_sys::{console, Document, HtmlElement, HtmlHeadElement, MouseEvent, Window};

// Events.

pub const EVT_CLICK: &str = "click";

// Selectors.

pub const H1TO6: &str = "h1,h2,h3,h4,h5,h6";

// Accessors.

pub fn window() -> Result<Window, Error> {
    web_sys::window().ok_or_else(not_defined("window"))
}

pub fn document() -> Result<Document, Error> {
    window()?.document().ok_or_else(not_defined("document"))
}

pub fn head() -> Result<HtmlHeadElement, Error> {
    document()?.head().ok_or_else(not_defined("head"))
}

pub fn body() -> Result<HtmlElement, Error> {
    document()?.body().ok_or_else(not_defined("body"))
}

// Create & remove elements.

pub fn create_element<T>(tag_name: &str) -> Result<T, Error>
where
    T: 'static + wasm_bindgen::JsCast,
{
    document()?
        .create_element(tag_name)?
        .dyn_into()
        .or_else(wrong_type("create_element"))
}

// Clear the node, removing all children.
// See https://stackoverflow.com/a/3955238 for why the first/last child combo.
pub fn clear_children(el: &HtmlElement) -> Result<(), Error> {
    while !el.first_child().is_none() {
        if let Some(node) = el.last_child() {
            el.remove_child(&node)?;
        }
    }

    Ok(())
}

// Event handlers.

pub fn on_evt(
    evt: &str,
    el_id: &str,
    callback: &'static dyn Fn(MouseEvent) -> Result<(), Error>,
) -> Result<(), Error> {
    let el: HtmlElement = document()?
        .get_element_by_id(el_id.into())
        .ok_or_else(throw(&format!("#{} not found", el_id)))?
        .dyn_into()
        .or_else(wrong_type("get_element_by_id"))?;
    on_el_evt(evt, &el, callback)
}

pub fn on_el_evt(
    evt: &str,
    el: &HtmlElement,
    callback: &'static dyn Fn(MouseEvent) -> Result<(), Error>,
) -> Result<(), Error> {
    let closure = Closure::wrap(Box::new(move |evt| {
        if let Err(err) = callback(evt) {
            console::log_2(&"event failed:".into(), &err);
        }
    }) as Box<dyn Fn(MouseEvent)>);
    el.add_event_listener_with_callback(evt, closure.as_ref().unchecked_ref())?;

    // Prevent JS from garbage-collecting the callback.
    closure.forget();

    Ok(())
}

pub fn on_click(
    el_id: &str,
    callback: &'static dyn Fn(MouseEvent) -> Result<(), Error>,
) -> Result<(), Error> {
    on_evt(EVT_CLICK, el_id, callback)
}

// Errors.

pub fn throw(text: &str) -> impl Fn() -> Error + '_ {
    move || Error::new(text)
}

pub fn not_defined(prop: &str) -> impl Fn() -> Error + '_ {
    move || Error::new(&format!("`{}` not defined", prop))
}

pub fn wrong_type<T, U>(func: &str) -> impl Fn(T) -> Result<U, Error> + '_ {
    move |_| Err(Error::new(&format!("{}() returned wrong type", func)))
}
