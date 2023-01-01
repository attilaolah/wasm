use serde::Deserialize;
use std::clone::Clone;
use std::marker::Copy;
use web_sys::{console, HtmlElement};
use yaml_front_matter::{Document, YamlFrontMatter};

use crate::dom::body;

lazy_static! {
    pub static ref NB: Notebook = Notebook {
        src: parse_src(&body().unwrap()),
    };
}

const CONFIG_DEFAULT: NotebookConfig = NotebookConfig { autorun: None };

pub struct Notebook {
    // MD source & metadata.
    pub src: Document<NotebookConfig>,
}

#[derive(Copy, Clone, Deserialize)]
pub struct NotebookConfig {
    autorun: Option<bool>,
}

impl NotebookConfig {
    pub fn autorun(self) -> bool {
        self.autorun.unwrap_or(false)
    }
}

fn parse_src(root: &HtmlElement) -> Document<NotebookConfig> {
    let inner_html = root.inner_html();
    let mut src_content = inner_html.trim();
    src_content = src_content.strip_prefix("<!--").unwrap_or(src_content);
    src_content = src_content.strip_suffix("-->").unwrap_or(src_content);
    src_content = src_content.trim();

    YamlFrontMatter::parse::<NotebookConfig>(src_content).unwrap_or_else(|err| {
        console::warn_2(
            &"failed to parse front matter:".into(),
            &err.to_string().into(),
        );
        // Don't fail if there is no front matter, just return the default.
        Document {
            metadata: CONFIG_DEFAULT,
            content: src_content.into(),
        }
    })
}
