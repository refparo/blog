use time::{OffsetDateTime, UtcOffset};
use typst::diag::FileResult;
use typst::foundations::{Bytes, Datetime, Dict};
use typst::syntax::{FileId, Source};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Feature, Library, LibraryExt, World};

use crate::cache::{FileCache, FileCacheSlot};
use crate::fonts;

pub struct BlogCompilation<'a, S = FileCacheSlot> {
  cache: &'a FileCache<S>,
  main: FileId,
  library: LazyHash<Library>,
  now: OffsetDateTime,
}

impl<'a, S> BlogCompilation<'a, S> {
  pub fn new(
    cache: &'a FileCache<S>,
    main: FileId,
    inputs: Dict,
    now: OffsetDateTime,
  ) -> Self {
    Self {
      cache,
      main,
      library: LazyHash::new(
        Library::builder()
          .with_features([Feature::Html].into_iter().collect())
          .with_inputs(inputs)
          .build(),
      ),
      now,
    }
  }
}

impl<S> World for BlogCompilation<'_, S>
where
  S: AsMut<FileCacheSlot> + From<FileCacheSlot> + Send,
{
  fn library(&self) -> &LazyHash<Library> {
    &self.library
  }

  fn book(&self) -> &LazyHash<FontBook> {
    fonts::book()
  }

  fn main(&self) -> FileId {
    self.main
  }

  fn source(&self, id: FileId) -> FileResult<Source> {
    self.cache.access(id)
  }

  fn file(&self, id: FileId) -> FileResult<Bytes> {
    self.cache.access(id)
  }

  fn font(&self, index: usize) -> Option<Font> {
    fonts::font(index)
  }

  fn today(&self, offset: Option<i64>) -> Option<Datetime> {
    let date = if let Some(offset) = offset {
      self
        .now
        .to_offset(UtcOffset::from_hms(offset as i8, 0, 0).ok()?)
        .date()
    } else {
      self.now.date()
    };
    Some(Datetime::Date(date))
  }
}
