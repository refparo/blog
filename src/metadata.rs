use std::sync::LazyLock;

use anyhow::{Result, anyhow};
use typst::Document;
use typst::foundations::{Dict, Label, Selector, Value};
use typst::introspection::MetadataElem;

static METADATA_SELECTOR: LazyLock<Selector> = LazyLock::new(|| {
  Selector::Label(Label::construct("metadata".into()).unwrap())
});

pub fn extract_metadata<D: Document>(document: &D) -> Result<Dict> {
  let elements = document.introspector().query(&METADATA_SELECTOR);
  if elements.len() > 1 {
    return Err(anyhow!("Found multiple elements with label <metadata>"));
  }
  let Some(element) = elements.into_iter().next() else {
    return Err(anyhow!("Couldn't find any <metadata>"));
  };
  let Ok(metadata) = element.unpack::<MetadataElem>() else {
    return Err(anyhow!(
      "The element labeled as <metadata> is not a metadata element"
    ));
  };
  let Value::Dict(dict) = metadata.value else {
    return Err(anyhow!("Metadata is not a dictionary"));
  };
  Ok(dict)
}
