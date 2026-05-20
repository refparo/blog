use std::collections::HashMap;
use std::sync::Mutex;

use chrono::Datelike;
use typst::diag::{FileResult, SourceResult, Warned};
use typst::foundations::{Bytes, Datetime, Dict};
use typst::syntax::{FileId, Source};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Document, Feature, Library, LibraryExt, World};

use crate::cache::{Cacheable, FileSlotCache};
use crate::fonts::FONTS;

mod cache;
mod fonts;

pub struct BlogWorld {
  files: Mutex<HashMap<FileId, FileSlot>>,
}

impl BlogWorld {
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
    typst::compile(&BlogCompilation::new(self, main, inputs))
  }

  pub fn mark_sweep_reset(&self, ids: impl IntoIterator<Item = FileId>) {
    let mut files = self.files.lock().unwrap();
    for id in ids {
      if let Some(file) = files.get_mut(&id) {
        file.stale = true;
      }
    }
    files.retain(|_, file| {
      if file.accessed || !file.stale {
        file.accessed = false;
        true
      } else {
        false
      }
    });
  }

  fn access<T: Cacheable>(&self, id: FileId) -> FileResult<T> {
    let mut files = self.files.lock().unwrap();
    if let Some(file) = files.get_mut(&id) {
      file.access()
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
        Entry::Occupied(entry) => entry.into_mut().access(),
        Entry::Vacant(entry) => {
          entry.insert(FileSlot::new(result.clone().to_cache(id)));
          Ok(result)
        }
      }
    }
  }
}

struct FileSlot {
  accessed: bool,
  stale: bool,
  cache: FileSlotCache,
}

impl FileSlot {
  fn new(cache: FileSlotCache) -> FileSlot {
    FileSlot {
      accessed: true,
      stale: false,
      cache,
    }
  }

  fn access<T: Cacheable>(&mut self) -> FileResult<T> {
    // This only tracks whether the slot is accessed during the previous
    // iteration, rather than whether it is actually needed (for example,
    // by a main that isn't refreshed during the last iteration.)
    // So this approach is only viable if we wait for the compilation of every
    // main to finish before starting the next iteration.
    // This may be already good enough, though.
    self.accessed = true;
    if self.stale {
      let result = Cacheable::update_cache(&mut self.cache)?;
      self.stale = false;
      Ok(result)
    } else {
      Cacheable::from_cache(&mut self.cache)
    }
  }
}

struct BlogCompilation<'a> {
  world: &'a BlogWorld,
  main: FileId,
  library: LazyHash<Library>,
  dependencies: Mutex<Vec<FileId>>,
  now: chrono::DateTime<chrono::Utc>,
}

impl<'a> BlogCompilation<'a> {
  pub fn new(world: &'a BlogWorld, main: FileId, inputs: Dict) -> Self {
    BlogCompilation {
      world,
      main,
      library: LazyHash::new(
        Library::builder()
          .with_features([Feature::Html].into_iter().collect())
          .with_inputs(inputs)
          .build(),
      ),
      dependencies: Mutex::new(Vec::new()),
      now: chrono::Utc::now(),
    }
  }
}

impl World for BlogCompilation<'_> {
  fn library(&self) -> &LazyHash<Library> {
    &self.library
  }

  fn book(&self) -> &LazyHash<FontBook> {
    FONTS.book()
  }

  fn main(&self) -> FileId {
    self.main
  }

  fn source(&self, id: FileId) -> FileResult<Source> {
    self.dependencies.lock().unwrap().push(id);
    self.world.access(id)
  }

  fn file(&self, id: FileId) -> FileResult<Bytes> {
    self.dependencies.lock().unwrap().push(id);
    self.world.access(id)
  }

  fn font(&self, index: usize) -> Option<Font> {
    FONTS.fonts().get(index).and_then(|slot| slot.get())
  }

  fn today(&self, offset: Option<i64>) -> Option<Datetime> {
    let date = if let Some(offset) = offset {
      self
        .now
        .with_timezone(
          &chrono::FixedOffset::east_opt(offset as i32 * 3600).unwrap(),
        )
        .date_naive()
    } else {
      self.now.naive_local().date()
    };
    Datetime::from_ymd(
      date.year(),
      date.month0() as u8 + 1,
      date.day0() as u8 + 1,
    )
  }
}
