use js_sys::Error;
use wasm_bindgen::prelude::wasm_bindgen;
use wee_alloc::WeeAlloc;

mod builtin_modules;
mod code_blocks;
mod dom;
mod layout;
mod modules;
mod notebook;
mod prism;

#[macro_use]
extern crate lazy_static;

#[global_allocator]
static ALLOC: WeeAlloc = WeeAlloc::INIT;

#[wasm_bindgen(start)]
pub fn main() -> Result<(), Error> {
    let nb = &notebook::NB;

    // UI setup.
    layout::set_meta_charset()?;
    layout::init_ui_content()?;
    layout::init_ui_theme()?;
    layout::init_ui_callbacks()?;
    prism::highlight_all_under(&dom::body()?)?;

    // We need to register all modules before preparing the cells.
    modules::register_all()?;

    // Prepare & run code blocks.
    code_blocks::prepare_all()?;
    if nb.src.metadata.autorun() {
        code_blocks::run_all()?;
    }

    Ok(())
}
