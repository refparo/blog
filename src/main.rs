use std::fs::{create_dir_all, write};
use std::path::Path;

use blog::BlogWorld;
use typst::Document;
use typst::foundations::{Dict, Label, NativeElement, Repr, Selector};
use typst::introspection::MetadataElem;
use typst::syntax::{FileId, VirtualPath};
use typst_html::HtmlDocument;

fn main() {
  let content_path = Path::new("content");
  let dist_path = Path::new("dist");
  let metadata_label =
    Selector::Label(Label::construct("metadata".into()).unwrap());

  let world = BlogWorld::new();
  let main_ids = ["content/posts/test1.typ", "content/posts/test2/index.typ"]
    .map(|filename| FileId::new(None, VirtualPath::new(filename)));
  for main in main_ids {
    let input_path = main.vpath().as_rootless_path();
    let document = world
      .compile::<HtmlDocument>(main, Dict::new())
      .output
      .unwrap();
    let metadata = document.introspector().query_unique(&metadata_label);
    if let Ok(metadata) = metadata {
      if metadata.func() == MetadataElem::ELEM {
        let metadata = metadata.field(MetadataElem::value.index()).unwrap();
        println!(
          "Found metadata in {}: {}",
          input_path.display(),
          metadata.repr()
        )
      } else {
        println!(
          "Found invalid metadata in {}: {}",
          input_path.display(),
          metadata.repr()
        )
      }
    } else {
      println!("Didn't find any metadata in {}", input_path.display())
    }
    let buf = typst_html::html(&document).unwrap();
    let output_file = dist_path
      .join(input_path.strip_prefix(content_path).unwrap())
      .with_extension("html");
    create_dir_all(output_file.parent().unwrap()).unwrap();
    write(output_file, buf).unwrap();
  }
}
