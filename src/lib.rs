use std::collections::HashMap;
use std::fs::{read, read_to_string};
use std::sync::{Arc, LazyLock, Mutex};

use chrono::Datelike;
use typst::diag::{FileError, FileResult};
use typst::foundations::{Bytes, Datetime};
use typst::syntax::{FileId, Source};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Feature, Library, LibraryExt, World};
use typst_kit::fonts::{FontSearcher, FontSlot, Fonts};

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
    &self.world.fonts.book
  }

  fn main(&self) -> FileId {
    self.main
  }

  fn source(&self, id: FileId) -> FileResult<Source> {
    let mut files = self.world.files.lock().unwrap();
    if let Some(file) = files.get_mut(&id) {
      file.source()
    } else {
      // I think it's better to take the risk of duplicating reads
      // rather than making everyone else wait for this read to finish.
      // Benchmarking also shows that even in serialized cases,
      // releasing the lock and re-acquiring after the read finishes is faster
      // than keeping the lock for the duration. (Why?)
      drop(files);
      let path = id.vpath().as_rooted_path();
      let buf =
        read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
      let source = Source::new(id, buf);
      use std::collections::hash_map::Entry;
      match self.world.files.lock().unwrap().entry(id) {
        Entry::Occupied(entry) => entry.into_mut().source(),
        Entry::Vacant(entry) => {
          entry.insert(FileSlot::new(FileSlotCache::Source(source.clone())));
          Ok(source)
        }
      }
    }
  }

  fn file(&self, id: FileId) -> FileResult<Bytes> {
    let mut files = self.world.files.lock().unwrap();
    if let Some(file) = files.get_mut(&id) {
      Ok(file.bytes())
    } else {
      drop(files);
      let path = id.vpath().as_rooted_path();
      let buf = read(path).map_err(|err| FileError::from_io(err, path))?;
      let bytes = Bytes::new(buf);
      use std::collections::hash_map::Entry;
      match self.world.files.lock().unwrap().entry(id) {
        Entry::Occupied(entry) => Ok(entry.into_mut().bytes()),
        Entry::Vacant(entry) => {
          entry.insert(FileSlot::new(FileSlotCache::Bytes(id, bytes.clone())));
          Ok(bytes)
        }
      }
    }
  }

  fn font(&self, index: usize) -> Option<Font> {
    self
      .world
      .fonts
      .fonts
      .get(index)
      .and_then(|slot| slot.get())
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

pub struct BlogWorld {
  library: LazyHash<Library>,
  fonts: LazyLock<LazyHashFonts>,
  files: Mutex<HashMap<FileId, FileSlot>>,
}

impl BlogWorld {
  pub fn new() -> BlogWorld {
    let library = Library::builder()
      .with_features([Feature::Html].into_iter().collect())
      .build();
    BlogWorld {
      library: LazyHash::new(library),
      // Since we only emit HTML, it may seem that we don't need fonts support.
      // However, remember that our pages might contain `#html.frame`s.
      // We lazily search the fonts for faster startup.
      fonts: LazyLock::new(|| LazyHashFonts::new(FontSearcher::new().search())),
      files: Mutex::new(HashMap::new()),
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

// We need this wrapper until the changes in `Fonts` are published in a release.
struct LazyHashFonts {
  book: LazyHash<FontBook>,
  fonts: Vec<FontSlot>,
}

impl LazyHashFonts {
  fn new(fonts: Fonts) -> LazyHashFonts {
    LazyHashFonts {
      book: LazyHash::new(fonts.book),
      fonts: fonts.fonts,
    }
  }
}

struct FileSlot {
  // stale: bool,
  cache: FileSlotCache,
}

enum FileSlotCache {
  Bytes(FileId, Bytes),
  Source(Source),
  Both(Source, Bytes),
}

impl FileSlot {
  fn new(cache: FileSlotCache) -> FileSlot {
    FileSlot {
      // stale: false,
      cache,
    }
  }

  // There is a redundant `clone()` in both of the following functions.
  // However, we can't eliminate them without using `unsafe` or introducing
  // an invalid state to `FileSlotCache`.
  fn bytes(&mut self) -> Bytes {
    match &self.cache {
      FileSlotCache::Bytes(_, bytes) | FileSlotCache::Both(_, bytes) => {
        bytes.clone()
      }
      FileSlotCache::Source(source) => {
        let bytes = Bytes::from_string(source.text().to_owned());
        self.cache = FileSlotCache::Both(source.clone(), bytes.clone());
        bytes
      }
    }
  }

  fn source(&mut self) -> FileResult<Source> {
    match &self.cache {
      FileSlotCache::Source(source) | FileSlotCache::Both(source, _) => {
        Ok(source.clone())
      }
      FileSlotCache::Bytes(id, bytes) => {
        let bytes = bytes.clone();
        let string = bytes
          .as_str()
          .map_err(|_| FileError::InvalidUtf8)?
          .to_owned();
        let source = Source::new(*id, string);
        self.cache = FileSlotCache::Both(source.clone(), bytes);
        Ok(source)
      }
    }
  }
}
