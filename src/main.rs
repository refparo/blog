use std::fs::write;
use std::path::Path;
use std::sync::Arc;

use blog::BlogWorld;
use typst::syntax::{FileId, VirtualPath};
use typst_html::HtmlDocument;

fn main() {
  let world = BlogWorld::new();
  let world_with_main = Arc::new(world).with_main(FileId::new(
    None,
    VirtualPath::new(Path::new("test.typ").canonicalize().unwrap()),
  ));
  let document = typst::compile::<HtmlDocument>(&world_with_main)
    .output
    .unwrap();
  // instead of stripping the html, we should template the html inside Typst.
  let buf = typst_html::html(&document).unwrap();
  write(Path::new("out.html"), buf).unwrap();
}
