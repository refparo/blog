use std::fs::write;
use std::path::Path;
use std::sync::Arc;

use blog::BlogWorld;
use typst::syntax::{FileId, VirtualPath};
use typst_html::HtmlDocument;

fn main() {
  let world = Arc::new(BlogWorld::new());
  let world_with_main = world.clone().with_main(FileId::new(
    None,
    VirtualPath::new(Path::new("entry0.typ").canonicalize().unwrap()),
  ));
  let document = typst::compile::<HtmlDocument>(&world_with_main)
    .output
    .unwrap();
  // instead of stripping the html, we should template the html inside Typst.
  let buf = typst_html::html(&document).unwrap();
  write(Path::new("out0.html"), buf).unwrap();
  let world_with_main = world.with_main(FileId::new(
    None,
    VirtualPath::new(Path::new("entry1.typ").canonicalize().unwrap()),
  ));
  let document = typst::compile::<HtmlDocument>(&world_with_main)
    .output
    .unwrap();
  // instead of stripping the html, we should template the html inside Typst.
  let buf = typst_html::html(&document).unwrap();
  write(Path::new("out1.html"), buf).unwrap();
}
