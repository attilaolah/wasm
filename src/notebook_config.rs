use serde::Deserialize;
use std::clone::Clone;
use std::error::Error;
use std::marker::Copy;
use web_sys::console;
use yaml_front_matter::{Document, YamlFrontMatter};

#[derive(Copy, Clone, Deserialize)]
pub struct NotebookConfig {
    autorun: Option<bool>,
}

static DEFAULT: NotebookConfig = NotebookConfig { autorun: None };

pub fn parse_doc(src: &str) -> Document<NotebookConfig> {
    YamlFrontMatter::parse::<NotebookConfig>(src).unwrap_or_else(|err: Box<dyn Error>| {
        console::warn_2(
            &"failed to parse front matter:".into(),
            &err.to_string().into(),
        );
        Document {
            metadata: DEFAULT,
            content: src.into(),
        }
    })
}

impl NotebookConfig {
    pub fn autorun(self) -> bool {
        self.autorun.unwrap_or(false)
    }
}
