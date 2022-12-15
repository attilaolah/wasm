use js_sys::Error;
use web_sys::{Document, HtmlElement, HtmlHeadElement, Window};

pub struct Notebook {}

impl Notebook {
    pub fn window(&self) -> Result<Window, Error> {
        web_sys::window().ok_or_else(|| {
            Error::new("`window` not found")
        })
    }

    pub fn document(&self) -> Result<Document, Error> {
        self.window()?.document().ok_or_else(|| {
            Error::new("`document` not found")
        })
    }

    pub fn head(&self) -> Result<HtmlHeadElement, Error> {
        self.document()?.head().ok_or_else(|| {
            Error::new("`head` not found")
        })
    }

    pub fn root(&self) -> Result<HtmlElement, Error> {
        self.document()?.body().ok_or_else(|| {
            Error::new("`body` not found")
        })
    }
}

