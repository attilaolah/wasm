use wasm_bindgen::prelude::*;

#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen(start)]
pub fn run() -> Result<(), JsValue> {
    let document = web_sys::window()
      .expect("`window` not found")
      .document().expect("`.document` not found");

    // Manufacture the element:
    let p = document.create_element("p")?;
    p.set_text_content(Some("Hello, Rust!"));

    // Append to the body:
    document
      .body().expect("`.body` not found")
      .append_child(&p)?;

    Ok(())
}
