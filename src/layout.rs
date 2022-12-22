use js_sys::{Array, Error, Function, Object, Promise, Reflect};
use pulldown_cmark::{html, Options, Parser};
use wasm_bindgen::closure::Closure;
use wasm_bindgen::JsCast;
use wasm_bindgen_futures::JsFuture;
use web_sys::{console, HtmlElement, HtmlMetaElement, HtmlTemplateElement, MouseEvent};

use crate::notebook::{window, Notebook};

impl Notebook {
    pub fn set_meta_charset(&self) -> Result<(), Error> {
        if !self.doc.query_selector("meta[charset]")?.is_none() {
            return Ok(());
        }

        let meta: HtmlMetaElement = self.create_element("meta")?;
        meta.set_attribute("charset", "utf-8")?;
        self.head
            .insert_before(&meta, self.head.first_child().as_ref())?;

        Ok(())
    }

    pub async fn init_ui_content(&self) -> Result<(), Error> {
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
        self.highlight()?;

        if self.src.metadata.autorun() {
            console::log_1(&"todo: autorun enabled, run all code blocks".into());
        }

        Ok(())
    }

    pub fn init_ui_callbacks(&self) -> Result<(), Error> {
        self.init_toggle_theme()?;
        self.init_toggle_theme_default()?;

        Ok(())
    }

    fn init_toggle_theme(&self) -> Result<(), Error> {
        let callback = Closure::wrap(Box::new(move |evt| {
            if let Err(err) = toggle_theme(evt) {
                console::log_2(&"click event failed:".into(), &err);
            }
        }) as Box<dyn Fn(_)>);
        self.root
            .query_selector("#toggle-theme".into())?
            .ok_or_else(|| Error::new("`#toggle-theme` not found"))?
            .add_event_listener_with_callback("click", callback.as_ref().unchecked_ref())?;

        // TODO: Don't .forget(), instead take ownership of the closure.
        callback.forget();

        Ok(())
    }

    fn init_toggle_theme_default(&self) -> Result<(), Error> {
        let callback = Closure::wrap(Box::new(move |evt| {
            if let Err(err) = toggle_theme_default(evt) {
                console::log_2(&"click event failed:".into(), &err);
            }
        }) as Box<dyn Fn(_)>);
        self.root
            .query_selector("#toggle-theme-default".into())?
            .ok_or_else(|| Error::new("`#toggle-theme-default` not found"))?
            .add_event_listener_with_callback("click", callback.as_ref().unchecked_ref())?;

        // TODO: Don't .forget(), instead take ownership of the closure.
        callback.forget();

        Ok(())
    }

    async fn template(&self) -> Result<String, Error> {
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

    fn highlight(&self) -> Result<(), Error> {
        let prism: Object = self
            .win
            .get("Prism")
            .ok_or_else(|| Error::new("`Prism` not found"))?;
        let func: Function = Reflect::get(&prism, &"highlightAllUnder".into())?.dyn_into()?;
        let args = Array::of1(&self.root);
        Reflect::apply(&func, &prism, &args)?;

        Ok(())
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

fn toggle_theme(evt: MouseEvent) -> Result<(), Error> {
    let target: HtmlElement = evt
        .target()
        .ok_or_else(|| Error::new("event target not found"))?
        .dyn_into()
        .or_else(wrong_type("target"))?;
    let class_list = target
        .owner_document()
        .ok_or_else(|| Error::new("owner document not found"))?
        .body()
        .ok_or_else(|| Error::new("body not found"))?
        .class_list();
    if class_list.contains("light") || class_list.contains("dark") {
        class_list.toggle("light")?;
        class_list.toggle("dark")?;
        return Ok(());
    }

    let dark_theme: bool = match window()?.match_media("(prefers-color-scheme: dark)")? {
        Some(mql) => mql.matches(),
        None => false,
    };
    class_list.toggle(if dark_theme { "light" } else { "dark" })?;

    Ok(())
}

fn toggle_theme_default(evt: MouseEvent) -> Result<(), Error> {
    let target: HtmlElement = evt
        .target()
        .ok_or_else(|| Error::new("event target not found"))?
        .dyn_into()
        .or_else(wrong_type("target"))?;
    target
        .owner_document()
        .ok_or_else(|| Error::new("owner document not found"))?
        .body()
        .ok_or_else(|| Error::new("body not found"))?
        .class_list()
        .remove_2("light", "dark")?;

    Ok(())
}
