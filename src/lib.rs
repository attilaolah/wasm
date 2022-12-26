use js_sys::Error;
use wasm_bindgen::prelude::wasm_bindgen;
use wee_alloc::WeeAlloc;

use crate::code_blocks::{prepare_all, run_all};
use crate::modules::register_all;
use crate::notebook::Notebook;

mod modules;
mod notebook;

mod code_blocks;
mod dom_helpers;
mod page_layout;

#[global_allocator]
static ALLOC: WeeAlloc = WeeAlloc::INIT;

#[wasm_bindgen(start)]
pub async fn main() -> Result<(), Error> {
    let mut nb = Notebook::parse()?;

    nb.set_meta_charset()?;
    nb.init_ui_content().await?;
    nb.init_ui_theme()?;
    nb.init_ui_callbacks()?;
    nb.highlight()?;

    // We need to register any modules before preparing the cells.
    register_all()?;

    prepare_all()?;
    if nb.src.metadata.autorun() {
        run_all()?;
    }

    Ok(())
}
