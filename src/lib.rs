use std::collections::HashMap;
use std::fs::{read, read_to_string};
use std::sync::{Arc, Mutex};

use chrono::Datelike;
use typst::diag::{FileError, FileResult};
use typst::foundations::{Bytes, Datetime};
use typst::syntax::{FileId, Source};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Feature, Library, LibraryExt, World};
use typst_kit::fonts::{FontSearcher, FontSlot, Fonts};

pub struct BlogWorld {
  library: LazyHash<Library>,
  book: LazyHash<FontBook>,
  sources: Mutex<HashMap<FileId, Source>>,
  files: Mutex<HashMap<FileId, Bytes>>,
  fonts: Vec<FontSlot>,
}

impl BlogWorld {
  pub fn new() -> BlogWorld {
    let library = Library::builder()
      .with_features([Feature::Html].into_iter().collect())
      .build();
    let Fonts { book, fonts } = FontSearcher::new().search();
    BlogWorld {
      library: LazyHash::new(library),
      book: LazyHash::new(book),
      sources: Mutex::new(HashMap::new()),
      files: Mutex::new(HashMap::new()),
      fonts,
    }
  }

  pub fn with_main(self: Arc<Self>, main: FileId) -> BlogWorldWithMain {
    BlogWorldWithMain {
      world: self,
      main,
      now: chrono::Utc::now(),
    }
  }
}

pub struct BlogWorldWithMain {
  world: Arc<BlogWorld>,
  main: FileId,
  now: chrono::DateTime<chrono::Utc>,
}

impl World for BlogWorldWithMain {
  fn library(&self) -> &LazyHash<Library> {
    &self.world.library
  }

  fn book(&self) -> &LazyHash<FontBook> {
    &self.world.book
  }

  fn main(&self) -> FileId {
    self.main
  }

  fn source(&self, id: FileId) -> FileResult<Source> {
    let sources = self.world.sources.lock().unwrap();
    if let Some(source) = sources.get(&id) {
      Ok(source.clone())
    } else {
      drop(sources);
      let path = id.vpath().as_rooted_path();
      let buf =
        read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
      Ok(
        self
          .world
          .sources
          .lock()
          .unwrap()
          .entry(id)
          .or_insert_with(|| Source::new(id, buf))
          .clone(),
      )
    }
  }

  fn file(&self, id: FileId) -> FileResult<Bytes> {
    let files = self.world.files.lock().unwrap();
    if let Some(file) = files.get(&id) {
      Ok(file.clone())
    } else {
      drop(files);
      let path = id.vpath().as_rooted_path();
      let buf = read(path).map_err(|err| FileError::from_io(err, path))?;
      Ok(
        self
          .world
          .files
          .lock()
          .unwrap()
          .entry(id)
          .or_insert_with(|| Bytes::new(buf))
          .clone(),
      )
    }
  }

  fn font(&self, index: usize) -> Option<Font> {
    self.world.fonts.get(index).and_then(|slot| slot.get())
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
