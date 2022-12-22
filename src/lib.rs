use js_sys::Error;
use wasm_bindgen::prelude::wasm_bindgen;
use web_sys::console;
use wee_alloc::WeeAlloc;

use crate::notebook::Notebook;

mod dom;
mod layout;
mod notebook;

#[global_allocator]
static ALLOC: WeeAlloc = WeeAlloc::INIT;

#[wasm_bindgen(start)]
pub async fn main() -> Result<(), Error> {
    let nb = Notebook::parse()?;

    nb.set_meta_charset()?;
    nb.init_ui_content().await?;
    nb.init_ui_theme()?;
    nb.init_ui_callbacks()?;
    nb.highlight()?;

    if nb.src.metadata.autorun() {
        console::log_1(&"todo: autorun enabled, run all code blocks".into());
    }

    Ok(())
}
