use blog::BlogCompiler;

fn main() -> anyhow::Result<()> {
  let compiler = BlogCompiler::new();
  compiler.compile_all()?;

  Ok(())
  // let main_ids = ["content/posts/test1.typ", "content/posts/test2/index.typ"]
  //   .map(|filename| FileId::new(None, VirtualPath::new(filename)));
  // for main in main_ids {
  //   let input_path = main.vpath().as_rootless_path();
  //   let document = world
  //     .compile::<HtmlDocument>(main, Dict::new())
  //     .output
  //     .unwrap();
  //   let metadata = extract_metadata(&document).unwrap();
  //   println!(
  //     "Found metadata in {}: {}",
  //     input_path.display(),
  //     metadata.repr()
  //   );
  //   let buf = typst_html::html(&document).unwrap();
  //   let output_file = dist_path
  //     .join(input_path.strip_prefix(content_path).unwrap())
  //     .with_extension("html");
  //   create_dir_all(output_file.parent().unwrap()).unwrap();
  //   write(output_file, buf).unwrap();
  // }
}
