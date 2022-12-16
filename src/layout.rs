use js_sys::Error;
use js_sys::JsString;
use pulldown_cmark::{html, Options, Parser};
use wasm_bindgen::JsCast;
use wasm_bindgen_futures::JsFuture;
use web_sys::{
    console, HtmlElement, HtmlMetaElement, HtmlTemplateElement, Request, RequestInit, RequestMode,
    Response,
};

use crate::notebook::Notebook;

const TEMPLATE_URL: &str = "notebook/template.html";

impl Notebook {
    pub async fn display_content(&self) -> Result<(), Error> {
        self.load_resources()?;
        self.set_meta_charset()?;

        let tpl_html = self.load_template().await?;

        let tpl: HtmlTemplateElement = self.create_element("template")?;
        tpl.set_inner_html(&tpl_html);

        match tpl.content().query_selector("#content")? {
            Some(el) => el.set_inner_html(&parse_markdown(&self.src.content)),
            None => {
                return Err(Error::new("#content not found in template"));
            }
        }

        clear_children(&self.root)?;
        self.root.append_child(&tpl.content())?;

        if self.src.metadata.autorun() {
            console::log_1(&"todo: autorun enabled, run all code blocks".into());
        }

        Ok(())
    }

    fn load_resources(&self) -> Result<(), Error> {
        // TODO: Load CSS!
        // TODO: Load JS!
        Ok(())
    }

    fn set_meta_charset(&self) -> Result<(), Error> {
        if !self.doc.query_selector("meta[charset]")?.is_none() {
            return Ok(());
        }

        let meta: HtmlMetaElement = self.create_element("meta")?;
        meta.set_attribute("charset", "utf-8")?;
        self.head
            .insert_before(&meta, self.head.first_child().as_ref())?;

        Ok(())
    }

    async fn load_template(&self) -> Result<String, Error> {
        let mut opts = RequestInit::new();
        opts.method("GET");
        opts.mode(RequestMode::Cors);

        let req = Request::new_with_str_and_init(TEMPLATE_URL.into(), &opts)?;
        req.headers().set("Accept", "text/html")?;

        let res_value = JsFuture::from(self.win.fetch_with_request(&req)).await?;
        let res: Response = res_value.dyn_into().or_else(wrong_type("fetch"))?;

        if !res.ok() {
            return Err(Error::new(&format!(
                "failed to load template: {} {:?}",
                res.status(),
                res.status_text().to_lowercase()
            ))
            .into());
        }

        let text_value = JsFuture::from(res.text()?).await?;
        let text: JsString = text_value.dyn_into().or_else(wrong_type("text"))?;

        Ok(text.into())
    }

    fn create_element<T>(&self, tag_name: &str) -> Result<T, Error>
    where
        T: 'static + wasm_bindgen::JsCast,
    {
        self.doc
            .create_element(tag_name)?
            .dyn_into()
            .or_else(wrong_type("create_element"))
    }
}

fn parse_markdown(content: &str) -> String {
    let mut buf = String::new();
    html::push_html(&mut buf, Parser::new_ext(content, Options::all()));
    buf.into()
}

// Clear the node.
// See https://stackoverflow.com/a/3955238 for why the first/last child combo.
fn clear_children(el: &HtmlElement) -> Result<(), Error> {
    while !el.first_child().is_none() {
        if let Some(node) = el.last_child() {
            el.remove_child(&node)?;
        }
    }

    Ok(())
}

fn wrong_type<T, U>(func: &str) -> impl Fn(T) -> Result<U, Error> + '_ {
    move |_| Err(Error::new(&format!("{}() returned wrong type", func)))
}
