use js_sys::Error;
use serde::Deserialize;
use std::clone::Clone;
use std::marker::Copy;
use wasm_bindgen::closure::Closure;
use web_sys::{console, Document, HtmlElement, HtmlHeadElement, MouseEvent, Window};
use yaml_front_matter::{Document as SrcDoc, YamlFrontMatter};

use crate::dom_helpers::{body, document, head, window};

pub struct Notebook {
    pub win: Window,
    pub doc: Document,
    pub head: HtmlHeadElement,
    pub body: HtmlElement,

    // MD source & metadata.
    pub src: SrcDoc<NotebookConfig>,

    // Callback event handlers.
    // These need to be kept alive for event handlers to work.
    pub on_clicks: Vec<Closure<dyn Fn(MouseEvent)>>,
}

#[derive(Copy, Clone, Deserialize)]
pub struct NotebookConfig {
    autorun: Option<bool>,
}

static DEFAULT: NotebookConfig = NotebookConfig { autorun: None };

impl Notebook {
    pub fn parse() -> Result<Self, Error> {
        Ok(Self {
            win: window()?,
            doc: document()?,
            head: head()?,
            body: body()?,
            src: parse_src()?,
            on_clicks: vec![],
        })
    }
}

impl NotebookConfig {
    pub fn autorun(self) -> bool {
        self.autorun.unwrap_or(false)
    }
}

fn parse_src() -> Result<SrcDoc<NotebookConfig>, Error> {
    let inner_html = body()?.inner_html();
    let mut src_content = inner_html.trim();
    src_content = src_content.strip_prefix("<!--").unwrap_or(src_content);
    src_content = src_content.strip_suffix("-->").unwrap_or(src_content);
    src_content = src_content.trim();

    Ok(
        YamlFrontMatter::parse::<NotebookConfig>(src_content).unwrap_or_else(|err| {
            console::warn_2(
                &"failed to parse front matter:".into(),
                &err.to_string().into(),
            );
            // Don't fail if there is no front matter, just return the default.
            SrcDoc {
                metadata: DEFAULT,
                content: src_content.into(),
            }
        }),
    )
}
