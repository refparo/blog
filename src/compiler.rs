use time::OffsetDateTime;
use typst::Document;
use typst::diag::{SourceResult, Warned};
use typst::foundations::Dict;
use typst::syntax::FileId;

use crate::cache::FileCache;
use crate::compilation::BlogCompilation;

pub struct BlogCompiler {
  cache: FileCache,
}

impl BlogCompiler {
  pub fn new() -> Self {
    Self {
      cache: FileCache::new(),
    }
  }

  pub fn compile<D: Document>(
    &self,
    main: FileId,
    inputs: Dict,
  ) -> Warned<SourceResult<D>> {
    typst::compile(&BlogCompilation::new(
      &self.cache,
      main,
      inputs,
      OffsetDateTime::now_local().unwrap(),
    ))
  }
}
