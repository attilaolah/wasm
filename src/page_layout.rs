use js_sys::{Array, Error, Function, Object, Promise, Reflect};
use pulldown_cmark::{html, Options, Parser};
use slug::slugify;
use wasm_bindgen::closure::Closure;
use wasm_bindgen::JsCast;
use wasm_bindgen_futures::JsFuture;
use web_sys::{console, HtmlElement, HtmlMetaElement, HtmlTemplateElement, MouseEvent};

use crate::code_blocks::run_all;
use crate::dom_helpers::{
    body, clear_children, create_element, not_defined, throw, window, wrong_type, H1TO6,
};
use crate::notebook::Notebook;

static DEFAULT_TITLE: &str = "Web Notebook";
static CONFIG_THEME: &str = "config:theme";

static DARK: &str = "dark";
static LIGHT: &str = "light";

impl Notebook {
    pub fn set_meta_charset(&self) -> Result<(), Error> {
        if self.doc.query_selector("meta[charset]")?.is_none() {
            let meta: HtmlMetaElement = create_element("meta")?;
            meta.set_attribute("charset", "utf-8")?;
            self.head
                .insert_before(&meta, self.head.first_child().as_ref())?;
        }

        Ok(())
    }

    pub async fn init_ui_content(&self) -> Result<(), Error> {
        let tpl_html = self.template().await?;

        let tpl: HtmlTemplateElement = create_element("template")?;
        tpl.set_inner_html(&tpl_html);

        match tpl.content().query_selector("#content")? {
            Some(el) => el.set_inner_html(&parse_markdown(&self.src.content)),
            None => {
                return Err(Error::new("#content not found in template"));
            }
        }

        let headings = tpl.content().query_selector_all(H1TO6)?;
        for i in 0..headings.length() {
            if let Some(node) = headings.get(i) {
                let el: HtmlElement = node.dyn_into().or_else(wrong_type("query_selector_all"))?;
                el.set_id(&slugify(el.inner_text()));
            }
        }

        // Set the page title.
        self.doc
            .set_title(&match tpl.content().query_selector("h1")? {
                Some(node) => {
                    let el: HtmlElement = node.dyn_into().or_else(wrong_type("query_selector"))?;
                    el.text_content().unwrap_or(DEFAULT_TITLE.to_string())
                }
                None => DEFAULT_TITLE.to_string(),
            });

        // Set the page content.
        clear_children(&self.body)?;
        self.body.append_child(&tpl.content())?;

        Ok(())
    }

    pub fn init_ui_theme(&self) -> Result<(), Error> {
        if let Some(ls) = self.win.local_storage()? {
            if let Some(theme) = ls.get_item(CONFIG_THEME)? {
                self.body.class_list().add_1(&theme)?
            }
        }

        Ok(())
    }

    pub fn init_ui_callbacks(&self) -> Result<(), Error> {
        self.init_run_all()?;
        self.init_toggle_theme()?;
        self.init_toggle_theme_default()?;

        Ok(())
    }

    pub fn highlight(&self) -> Result<(), Error> {
        let prism: Object = self.win.get("Prism").ok_or_else(not_defined("Prism"))?;
        let func: Function = Reflect::get(&prism, &"highlightAllUnder".into())?.dyn_into()?;
        let args = Array::of1(&self.body);
        Reflect::apply(&func, &prism, &args)?;

        Ok(())
    }

    async fn template(&self) -> Result<String, Error> {
        // Load the template promise set by the preloader.
        let notebook: Object = self
            .win
            .get("notebook")
            .ok_or_else(not_defined("notebook"))?;
        let tpl: Promise = Reflect::get(&notebook, &"template".into())?.dyn_into()?;
        JsFuture::from(tpl)
            .await?
            .as_string()
            .ok_or_else(throw("`template` did not resolve with a string"))
    }

    fn init_run_all(&self) -> Result<(), Error> {
        let callback = Closure::wrap(Box::new(move |_| {
            if let Err(err) = run_all() {
                console::log_2(&"click event failed:".into(), &err);
            }
        }) as Box<dyn Fn(MouseEvent)>);
        self.body
            .query_selector("#run-all".into())?
            .ok_or_else(throw("#run-all not found"))?
            .add_event_listener_with_callback("click", callback.as_ref().unchecked_ref())?;

        // TODO: Don't .forget(), instead take ownership of the closure.
        callback.forget();

        Ok(())
    }

    fn init_toggle_theme(&self) -> Result<(), Error> {
        let callback = Closure::wrap(Box::new(move |_| {
            if let Err(err) = toggle_theme() {
                console::log_2(&"click event failed:".into(), &err);
            }
        }) as Box<dyn Fn(MouseEvent)>);
        self.body
            .query_selector("#toggle-theme".into())?
            .ok_or_else(throw("#toggle-theme not found"))?
            .add_event_listener_with_callback("click", callback.as_ref().unchecked_ref())?;

        // TODO: Don't .forget(), instead take ownership of the closure.
        callback.forget();

        Ok(())
    }

    fn init_toggle_theme_default(&self) -> Result<(), Error> {
        let callback = Closure::wrap(Box::new(move |_| {
            if let Err(err) = toggle_theme_default() {
                console::log_2(&"click event failed:".into(), &err);
            }
        }) as Box<dyn Fn(MouseEvent)>);
        self.body
            .query_selector("#toggle-theme-default".into())?
            .ok_or_else(throw("#toggle-theme-default not found"))?
            .add_event_listener_with_callback("click", callback.as_ref().unchecked_ref())?;

        // TODO: Don't .forget(), instead take ownership of the closure.
        callback.forget();

        Ok(())
    }
}

fn parse_markdown(content: &str) -> String {
    let mut buf = String::new();
    html::push_html(&mut buf, Parser::new_ext(content, Options::all()));
    buf.into()
}

fn toggle_theme() -> Result<(), Error> {
    let win = window()?;
    let class_list = body()?.class_list();

    let old_theme = if class_list.contains(DARK) {
        // Explicit DARK preference takes precedence over LIGHT preference.
        DARK
    } else if class_list.contains(LIGHT) {
        LIGHT
    } else {
        match win.match_media("(prefers-color-scheme: dark)")? {
            Some(mql) => {
                if mql.matches() {
                    DARK
                } else {
                    LIGHT
                }
            }
            None => LIGHT,
        }
    };
    let new_theme = if old_theme == DARK { LIGHT } else { DARK };

    if let Some(ls) = win.local_storage()? {
        if let Err(err) = ls.set_item(CONFIG_THEME, new_theme) {
            console::warn_2(&"local_storage.set_item failed:".into(), &err);
        }
    }

    class_list.toggle_with_force(old_theme, false)?;
    class_list.toggle_with_force(new_theme, true)?;

    Ok(())
}

fn toggle_theme_default() -> Result<(), Error> {
    body()?.class_list().remove_2(LIGHT, DARK)?;

    if let Some(ls) = window()?.local_storage()? {
        ls.remove_item(CONFIG_THEME)?;
    }

    Ok(())
}
