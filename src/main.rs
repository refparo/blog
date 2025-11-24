use std::fs::write;
use std::io::BufRead;
use std::path::Path;
use std::sync::Arc;

use blog::{BlogMain, BlogWorld};
use typst::World;
use typst::syntax::{FileId, VirtualPath};
use typst_html::HtmlDocument;

fn main() {
  let world = Arc::new(BlogWorld::new());
  let main_ids = ["entry0.typ", "entry1.typ"].map(|filename| {
    FileId::new(
      None,
      VirtualPath::new(Path::new(filename).canonicalize().unwrap()),
    )
  });
  let mut mains = main_ids.map(|id| BlogMain::new(world.clone(), id));
  let stdin = std::io::stdin();
  loop {
    for main in mains.iter() {
      let document = typst::compile::<HtmlDocument>(&main).output.unwrap();
      let buf = typst_html::html(&document).unwrap();
      write(
        main
          .main()
          .vpath()
          .as_rooted_path()
          .with_added_extension("html"),
        buf,
      )
      .unwrap();
    }
    let mut buf = String::new();
    if let Ok(0) | Err(_) = stdin.lock().read_line(&mut buf) {
      break;
    }
    world.mark_sweep_reset(main_ids);
    for main in mains.iter_mut() {
      main.reset();
    }
  }
}
