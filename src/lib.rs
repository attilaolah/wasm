use wasm_bindgen::prelude::*;

mod layout;
mod notebook_config;

#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen(start)]
pub fn run() -> Result<(), JsValue> {
    let win = web_sys::window().expect("`window` not found");
    let doc = win.document().expect("`window.document` not found");
    let body = doc.body().expect("`window.document.body` not found");

    layout::display_content(&doc, &body)?;

    Ok(())
}
