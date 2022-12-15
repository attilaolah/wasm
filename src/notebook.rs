use js_sys::Error;
use web_sys::{Document, HtmlElement, HtmlHeadElement, Window};

pub struct Notebook {
    pub win: Window,
    pub doc: Document,
    pub head: HtmlHeadElement,
    pub root: HtmlElement,
}

impl Notebook {
    pub fn new() -> Result<Self, Error> {
        let win = web_sys::window().ok_or_else(|| Error::new("`window` not found"))?;
        let doc = win
            .document()
            .ok_or_else(|| Error::new("`document` not found"))?;
        let head = doc.head().ok_or_else(|| Error::new("`head` not found"))?;
        let root = doc.body().ok_or_else(|| Error::new("`body` not found"))?;

        Ok(Self {
            win,
            doc,
            head,
            root,
        })
    }
}
