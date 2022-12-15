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
use crate::notebook_config;

impl Notebook {
    pub fn load_external(&self) -> Result<(), JsValue> {
        // TODO: Load CSS!
        // TODO: Load JS!
        Ok(())
    }

    pub async fn display_content(&self) -> Result<(), JsValue> {
        let (cfg, md_html) = self.parse_markdown();
        let tpl_html = load_template().await?;

        let tpl: HtmlTemplateElement = self.doc.create_element("template")?.dyn_into()?;
        tpl.set_inner_html(&tpl_html);

        match tpl.content().query_selector("#content")? {
            Some(el) => el.set_inner_html(&md_html),
            None => {
                return Err("#content not found in template".into());
            }
        }

        clear_children(&self.root)?;
        self.ensure_meta_charset()?;
        self.root.append_child(&tpl.content())?;

        if cfg.autorun() {
            console::log_1(&"todo: autorun enabled, run all code blocks".into());
        }

        Ok(())
    }

    fn ensure_meta_charset(&self) -> Result<(), Error> {
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

    fn parse_markdown(&self) -> (notebook_config::NotebookConfig, String) {
        let inner_html = self.root.inner_html();
        let mut markdown_src = inner_html.trim();
        markdown_src = markdown_src.strip_prefix("<!--").unwrap_or(markdown_src);
        markdown_src = markdown_src.strip_suffix("-->").unwrap_or(markdown_src);
        markdown_src = markdown_src.trim();

        let md_doc = notebook_config::parse_doc(&markdown_src);
        markdown_src = &md_doc.content;

        let mut buf = String::new();
        html::push_html(&mut buf, Parser::new_ext(markdown_src, Options::all()));

        (md_doc.metadata, buf.into())
    }
}

async fn load_template() -> Result<String, JsValue> {
    let mut opts = RequestInit::new();
    opts.method("GET");
    opts.mode(RequestMode::Cors);

    let req = Request::new_with_str_and_init("/notebook/template.html".into(), &opts)?;
    req.headers().set("Accept", "text/html")?;

    let window = web_sys::window().unwrap();
    let res_value = JsFuture::from(window.fetch_with_request(&req)).await?;

    // `res_value` is a `Response` object.
    assert!(res_value.is_instance_of::<Response>());
    let res: Response = res_value.dyn_into().unwrap();

    let text_value = JsFuture::from(res.text()?).await?;

    let text: JsString = text_value.dyn_into().unwrap();

    Ok(text.into())
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
