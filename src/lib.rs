use js_sys::Error;
use wasm_bindgen::prelude::wasm_bindgen;

use crate::notebook::Notebook;

mod layout;
mod notebook;
mod notebook_config;

#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: WeeAlloc = WeeAlloc::INIT;

#[wasm_bindgen(start)]
pub async fn main() -> Result<(), Error> {
    let nb = Notebook::new()?;

    nb.load_external()?;
    nb.display_content().await?;

    Ok(())
}
