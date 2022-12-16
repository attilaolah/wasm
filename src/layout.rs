use js_sys::Error;
use js_sys::JsString;
use pulldown_cmark::{html, Options, Parser};
use wasm_bindgen::{JsCast, JsValue};
use wasm_bindgen_futures::JsFuture;
use web_sys::{
    console, HtmlElement, HtmlMetaElement, HtmlTemplateElement, Request, RequestInit, RequestMode,
    Response,
};

use crate::notebook::Notebook;

impl Notebook {
    pub async fn display_content(&self) -> Result<(), JsValue> {
        self.load_resources()?;
        self.set_meta_charset()?;

        let tpl_html = self.load_template().await?;

        let tpl: HtmlTemplateElement = self.doc.create_element("template")?.dyn_into()?;
        tpl.set_inner_html(&tpl_html);

        match tpl.content().query_selector("#content")? {
            Some(el) => el.set_inner_html(&parse_markdown(&self.src.content)),
            None => {
                return Err("#content not found in template".into());
            }
        }

        clear_children(&self.root)?;
        self.root.append_child(&tpl.content())?;

        if self.src.metadata.autorun() {
            console::log_1(&"todo: autorun enabled, run all code blocks".into());
        }

        Ok(())
    }

    fn load_resources(&self) -> Result<(), JsValue> {
        // TODO: Load CSS!
        // TODO: Load JS!
        Ok(())
    }

    fn set_meta_charset(&self) -> Result<(), Error> {
        if !self.doc.query_selector("meta[charset]")?.is_none() {
            return Ok(());
        }

        let meta: HtmlMetaElement = self
            .doc
            .create_element("meta")?
            .dyn_into()
            .or_else(|_| Err(Error::new("create_element() returned wrong type")))?;
        meta.set_attribute("charset", "utf-8")?;
        self.head
            .insert_before(&meta, self.head.first_child().as_ref())?;

        Ok(())
    }

    async fn load_template(&self) -> Result<String, JsValue> {
        let mut opts = RequestInit::new();
        opts.method("GET");
        opts.mode(RequestMode::Cors);

        let req = Request::new_with_str_and_init("/notebook/template.html".into(), &opts)?;
        req.headers().set("Accept", "text/html")?;

        let res_value = JsFuture::from(self.win.fetch_with_request(&req)).await?;
        let res: Response = res_value.dyn_into().unwrap();

        if !res.ok() {
            return Err(Error::new(&format!(
                "failed to load template: {} {:?}",
                res.status(),
                res.status_text().to_lowercase()
            ))
            .into());
        }

        let text_value = JsFuture::from(res.text()?).await?;
        let text: JsString = text_value.dyn_into().unwrap();

        Ok(text.into())
    }
}

fn parse_markdown(content: &str) -> String {
    let mut buf = String::new();
    html::push_html(&mut buf, Parser::new_ext(content, Options::all()));
    buf.into()
}

// Clear the node.
// See https://stackoverflow.com/a/3955238 for why the first/last child combo.
fn clear_children(el: &HtmlElement) -> Result<(), JsValue> {
    while !el.first_child().is_none() {
        if let Some(node) = el.last_child() {
            el.remove_child(&node)?;
        }
    }

    Ok(())
}
