use std::fs::{create_dir_all, write};
use std::path::Path;

use blog::{BlogCompiler, extract_metadata};
use typst::foundations::{Dict, Repr};
use typst::syntax::{FileId, VirtualPath};
use typst_html::HtmlDocument;

fn main() {
  let content_path = Path::new("content");
  let dist_path = Path::new("dist");

  let world = BlogCompiler::new();
  let main_ids = ["content/posts/test1.typ", "content/posts/test2/index.typ"]
    .map(|filename| FileId::new(None, VirtualPath::new(filename)));
  for main in main_ids {
    let input_path = main.vpath().as_rootless_path();
    let document = world
      .compile::<HtmlDocument>(main, Dict::new())
      .output
      .unwrap();
    let metadata = extract_metadata(&document).unwrap();
    println!(
      "Found metadata in {}: {}",
      input_path.display(),
      metadata.repr()
    );
    let buf = typst_html::html(&document).unwrap();
    let output_file = dist_path
      .join(input_path.strip_prefix(content_path).unwrap())
      .with_extension("html");
    create_dir_all(output_file.parent().unwrap()).unwrap();
    write(output_file, buf).unwrap();
  }
}
