use js_sys::Error;
use wasm_bindgen::prelude::wasm_bindgen;

use crate::notebook::Notebook;

mod layout;
mod notebook;

#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: WeeAlloc = WeeAlloc::INIT;

#[wasm_bindgen(start)]
pub async fn main() -> Result<(), Error> {
    let nb = Notebook::parse()?;

    nb.set_meta_charset()?;
    nb.init_ui_content().await?;
    nb.init_ui_callbacks()?;

    Ok(())
}
