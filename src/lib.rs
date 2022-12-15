use js_sys::Error;
use wasm_bindgen::prelude::wasm_bindgen;

mod layout;
mod notebook_config;

#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: WeeAlloc = WeeAlloc::INIT;

#[wasm_bindgen(start)]
pub async fn main() -> Result<(), Error> {
    let win = web_sys::window().ok_or(Error::new("`window` not found"))?;
    let doc = win.document().ok_or(Error::new("`document` not found"))?;
    let body = doc.body().ok_or(Error::new("`body` not found"))?;

    layout::load_external()?;
    layout::display_content(&doc, &body).await?;

    Ok(())
}
