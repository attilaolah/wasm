use js_sys::JsString;
use js_sys::{Error, Object, Promise, Reflect};
use pulldown_cmark::{html, Options, Parser};
use wasm_bindgen::JsCast;
use wasm_bindgen_futures::JsFuture;
use web_sys::{
    console, HtmlElement, HtmlLinkElement, HtmlMetaElement, HtmlTemplateElement, Request,
    RequestInit, RequestMode, Response,
};

use crate::notebook::Notebook;

const TEMPLATE_URL: &str = "notebook/template.html";

impl Notebook {
    pub async fn display_content(&self) -> Result<(), Error> {
        self.load_resources()?;
        self.set_meta_charset()?;

        let tpl_html = self.template().await?;

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
        // TODO: Load any additional styles if needed.

        Ok(())
    }

    fn load_css(&self, url: &str) -> Result<(), Error> {
        let link: HtmlLinkElement = self.create_element("link")?;
        link.set_attribute("rel", "stylesheet")?;
        link.set_attribute("href", url)?;
        self.head.append_child(&link)?;

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

    pub async fn template(&self) -> Result<String, Error> {
        // Load the template promise set by the preloader.
        let notebook: Object = self
            .win
            .get("notebook")
            .ok_or_else(|| Error::new("`notebook` not found"))?;
        let tpl: Promise = Reflect::get(&notebook, &"template".into())?.dyn_into()?;
        JsFuture::from(tpl)
            .await?
            .as_string()
            .ok_or_else(|| Error::new("`template` did not resolve with a string"))
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
