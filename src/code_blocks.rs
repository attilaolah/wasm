use js_sys::Error;
use web_sys::console;

pub fn run_all() -> Result<(), Error> {
    console::log_1(&"todo: run all code blocks".into());

    Ok(())
}
