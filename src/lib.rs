use js_sys::Error;
use wasm_bindgen::prelude::wasm_bindgen;
use wee_alloc::WeeAlloc;

use crate::code_blocks::{prepare_all, run_all};
use crate::dom_helpers::body;
use crate::modules::register_all;
use crate::notebook::Notebook;
use crate::page_layout::highlight_all_under;

mod builtin_modules;
mod code_blocks;
mod dom_helpers;
mod modules;
mod notebook;
mod page_layout;

#[global_allocator]
static ALLOC: WeeAlloc = WeeAlloc::INIT;

#[wasm_bindgen(start)]
pub async fn main() -> Result<(), Error> {
    let mut nb = Notebook::parse()?;

    // UI setup.
    nb.set_meta_charset()?;
    nb.init_ui_content().await?;
    nb.init_ui_theme()?;
    nb.init_ui_callbacks()?;
    highlight_all_under(&body()?)?;

    // We need to register all modules before preparing the cells.
    register_all()?;

    // Prepare & run code blocks.
    prepare_all()?;
    if nb.src.metadata.autorun() {
        run_all()?;
    }

    Ok(())
}
