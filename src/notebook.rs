use js_sys::Error;
use serde::Deserialize;
use std::clone::Clone;
use std::marker::Copy;
use web_sys::console;
use yaml_front_matter::{Document, YamlFrontMatter};

use crate::dom_helpers::body;

pub struct Notebook {
    // MD source & metadata.
    pub src: Document<NotebookConfig>,
}

#[derive(Copy, Clone, Deserialize)]
pub struct NotebookConfig {
    autorun: Option<bool>,
}

const DEFAULT: NotebookConfig = NotebookConfig { autorun: None };

impl Notebook {
    pub fn parse() -> Result<Self, Error> {
        Ok(Self { src: parse_src()? })
    }
}

impl NotebookConfig {
    pub fn autorun(self) -> bool {
        self.autorun.unwrap_or(false)
    }
}

fn parse_src() -> Result<Document<NotebookConfig>, Error> {
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
            Document {
                metadata: DEFAULT,
                content: src_content.into(),
            }
        }),
    )
}
