use std::collections::HashSet;
use std::sync::Mutex;

use time::OffsetDateTime;
use typst::diag::FileResult;
use typst::foundations::{Bytes, Datetime, Dict};
use typst::syntax::{FileId, Source};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Library, World};
use typst_html::HtmlDocument;

use crate::cache::Cacheable;
use crate::compiler::{BlogCompilation, BlogCompiler, BlogWorld};
use crate::metadata::extract_metadata;

pub struct BlogDevServer {
  inner: BlogCompiler,
  // outputs: Mutex<HashMap<FileId, DevCompileOutput>>,
}

impl BlogDevServer {
  pub fn new() -> Self {
    Self {
      inner: BlogCompiler::new(),
      // outputs: Mutex::new(HashMap::new()),
    }
  }

  pub fn compile(&self, main: FileId, inputs: Dict) -> DevCompileOutput {
    let compilation = BlogDevCompilation::new(self, main, inputs);
    let result = typst::compile::<HtmlDocument>(&compilation);
    let document = result.output.unwrap();
    DevCompileOutput {
      content: typst_html::html(&document).unwrap(),
      metadata: extract_metadata(&document).ok(),
      dependencies: compilation.dependencies.into_inner().unwrap(),
    }
  }
}

impl BlogWorld for BlogDevServer {
  fn access<T: Cacheable>(&self, id: FileId) -> FileResult<T> {
    self.inner.access(id)
  }
}

pub struct DevCompileOutput {
  pub content: String,
  pub metadata: Option<Dict>,
  pub dependencies: HashSet<FileId>,
}

struct BlogDevCompilation<'a> {
  inner: BlogCompilation<'a, BlogDevServer>,
  dependencies: Mutex<HashSet<FileId>>,
}

impl<'a> BlogDevCompilation<'a> {
  fn new(world: &'a BlogDevServer, main: FileId, inputs: Dict) -> Self {
    Self {
      inner: BlogCompilation::new(
        world,
        main,
        inputs,
        OffsetDateTime::now_local().unwrap(),
      ),
      dependencies: Mutex::new(HashSet::new()),
    }
  }
}

impl<'a> World for BlogDevCompilation<'a> {
  fn library(&self) -> &LazyHash<Library> {
    self.inner.library()
  }

  fn book(&self) -> &LazyHash<FontBook> {
    self.inner.book()
  }

  fn main(&self) -> FileId {
    self.inner.main()
  }

  fn source(&self, id: FileId) -> FileResult<Source> {
    self.dependencies.lock().unwrap().insert(id);
    self.inner.source(id)
  }

  fn file(&self, id: FileId) -> FileResult<Bytes> {
    self.dependencies.lock().unwrap().insert(id);
    self.inner.file(id)
  }

  fn font(&self, index: usize) -> Option<Font> {
    self.inner.font(index)
  }

  fn today(&self, offset: Option<i64>) -> Option<Datetime> {
    self.inner.today(offset)
  }
}
