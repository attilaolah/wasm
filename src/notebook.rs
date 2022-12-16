use js_sys::{Error, Object, Promise, Reflect};
use serde::Deserialize;
use std::clone::Clone;
use std::marker::Copy;
use wasm_bindgen::JsCast;
use wasm_bindgen_futures::JsFuture;
use web_sys::console;
use web_sys::{Document, HtmlElement, HtmlHeadElement, Window};
use yaml_front_matter::{Document as SrcDoc, YamlFrontMatter};

pub struct Notebook {
    pub win: Window,
    pub doc: Document,
    pub head: HtmlHeadElement,
    pub root: HtmlElement,

    pub src: SrcDoc<NotebookConfig>,
}

#[derive(Copy, Clone, Deserialize)]
pub struct NotebookConfig {
    autorun: Option<bool>,
}

static DEFAULT: NotebookConfig = NotebookConfig { autorun: None };

impl Notebook {
    pub fn parse() -> Result<Self, Error> {
        let win = web_sys::window().ok_or_else(|| Error::new("`window` not found"))?;
        let doc = win
            .document()
            .ok_or_else(|| Error::new("`document` not found"))?;
        let head = doc.head().ok_or_else(|| Error::new("`head` not found"))?;
        let root = doc.body().ok_or_else(|| Error::new("`body` not found"))?;

        let inner_html = root.inner_html();
        let mut src_content = inner_html.trim();
        src_content = src_content.strip_prefix("<!--").unwrap_or(src_content);
        src_content = src_content.strip_suffix("-->").unwrap_or(src_content);
        src_content = src_content.trim();

        let src = YamlFrontMatter::parse::<NotebookConfig>(src_content).unwrap_or_else(|err| {
            console::warn_2(
                &"failed to parse front matter:".into(),
                &err.to_string().into(),
            );
            // Don't fail if there is no front matter, just return the default.
            SrcDoc {
                metadata: DEFAULT,
                content: src_content.into(),
            }
        });

        Ok(Self {
            win,
            doc,
            head,
            root,
            src,
        })
    }
}

impl NotebookConfig {
    pub fn autorun(self) -> bool {
        self.autorun.unwrap_or(false)
    }
}
