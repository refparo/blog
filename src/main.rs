use std::fs::write;
use std::path::Path;
use std::sync::Arc;

use blog::BlogWorld;
use typst::layout::PagedDocument;
use typst::syntax::{FileId, VirtualPath};
use typst_pdf::PdfOptions;

fn main() {
  let world = BlogWorld::new();
  let world_with_main = Arc::new(world).with_main(FileId::new(
    None,
    VirtualPath::new(Path::new("test.typ").canonicalize().unwrap()),
  ));
  let document = typst::compile::<PagedDocument>(&world_with_main)
    .output
    .unwrap();
  let buf = typst_pdf::pdf(&document, &PdfOptions::default()).unwrap();
  write(Path::new("out.pdf"), buf).unwrap();
}
