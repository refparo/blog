use std::collections::HashMap;
use std::sync::Mutex;

use time::{OffsetDateTime, UtcOffset};
use typst::diag::{FileResult, SourceResult, Warned};
use typst::foundations::{Bytes, Datetime, Dict};
use typst::syntax::{FileId, Source};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Document, Feature, Library, LibraryExt, World};

use crate::cache::{Cacheable, FileCache};
use crate::fonts;

pub struct BlogCompiler {
  files: Mutex<HashMap<FileId, FileCache>>,
}

impl BlogCompiler {
  pub fn new() -> Self {
    Self {
      files: Mutex::new(HashMap::new()),
    }
  }

  pub fn compile<D: Document>(
    &self,
    main: FileId,
    inputs: Dict,
  ) -> Warned<SourceResult<D>> {
    typst::compile(&BlogCompilation::new(
      self,
      main,
      inputs,
      OffsetDateTime::now_local().unwrap(),
    ))
  }
}

pub trait BlogWorld {
  fn access<T: Cacheable>(&self, id: FileId) -> FileResult<T>;
}

impl BlogWorld for BlogCompiler {
  fn access<T: Cacheable>(&self, id: FileId) -> FileResult<T> {
    let mut files = self.files.lock().unwrap();
    if let Some(file) = files.get_mut(&id) {
      Cacheable::from_cache(file)
    } else {
      // I think it's better to take the risk of duplicating reads
      // rather than making everyone else wait for this read to finish.
      // Benchmarking also shows that even in serialized cases,
      // releasing the lock and re-acquiring after the read finishes is faster
      // than keeping the lock for the duration. (Why?)
      drop(files);
      let result = <T as Cacheable>::read(id)?;
      use std::collections::hash_map::Entry;
      match self.files.lock().unwrap().entry(id) {
        Entry::Occupied(entry) => Cacheable::from_cache(entry.into_mut()),
        Entry::Vacant(entry) => {
          entry.insert(result.clone().to_cache(id));
          Ok(result)
        }
      }
    }
  }
}

pub struct BlogCompilation<'a, W> {
  world: &'a W,
  main: FileId,
  library: LazyHash<Library>,
  now: OffsetDateTime,
}

impl<'a, W> BlogCompilation<'a, W> {
  pub fn new(
    world: &'a W,
    main: FileId,
    inputs: Dict,
    now: OffsetDateTime,
  ) -> Self {
    Self {
      world,
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

impl<W: BlogWorld + Sync> World for BlogCompilation<'_, W> {
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
    self.world.access(id)
  }

  fn file(&self, id: FileId) -> FileResult<Bytes> {
    self.world.access(id)
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
