use std::sync::LazyLock;

use anyhow::anyhow;
use typst::foundations::{Dict, Label, Output, Selector, Value};
use typst::introspection::MetadataElem;

use crate::config::METADATA_LABEL_NAME;

static METADATA_SELECTOR: LazyLock<Selector> = LazyLock::new(|| {
  Selector::Label(Label::construct(METADATA_LABEL_NAME.into()).unwrap())
});

pub fn extract_metadata<T: Output>(output: &T) -> anyhow::Result<Dict> {
  let elements = output.introspector().query(&METADATA_SELECTOR);
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
