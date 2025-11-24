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

pub struct BlogMain {
  world: Arc<BlogWorld>,
  main: FileId,
  dependencies: Mutex<Vec<FileId>>,
  now: chrono::DateTime<chrono::Utc>,
}

impl BlogMain {
  pub fn new(world: Arc<BlogWorld>, main: FileId) -> BlogMain {
    BlogMain {
      world,
      main,
      dependencies: Mutex::new(Vec::new()),
      now: chrono::Utc::now(),
    }
  }

  pub fn reset(&mut self) {
    self.dependencies.lock().unwrap().clear();
    self.now = chrono::Utc::now();
  }
}

impl World for BlogMain {
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
    self.dependencies.lock().unwrap().push(id);
    self.world.access(id)
  }

  fn file(&self, id: FileId) -> FileResult<Bytes> {
    self.dependencies.lock().unwrap().push(id);
    self.world.access(id)
  }

  fn font(&self, index: usize) -> Option<Font> {
    self.world.font(index)
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

  fn font(&self, index: usize) -> Option<Font> {
    self.fonts.fonts.get(index).and_then(|slot| slot.get())
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
  accessed: bool,
  stale: bool,
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
      accessed: true,
      stale: false,
      cache,
    }
  }

  fn access<T: Cacheable>(&mut self) -> FileResult<T> {
    // This only tracks whether the slot is accessed during the previous
    // iteration, rather than whether it is actually needed (for example,
    // by a main that isn't refreshed during the last iteration.)
    // So this appraoch is only viable if we wait for the compilation of every
    // main to finish before starting the next iteration.
    // This may be already good enough, though.
    self.accessed = true;
    if self.stale {
      let id = self.id();
      let result = <T as Cacheable>::update_cache(&mut self.cache, id)?;
      self.stale = false;
      Ok(result)
    } else {
      Cacheable::from_cache(&mut self.cache)
    }
  }

  fn id(&self) -> FileId {
    match &self.cache {
      FileSlotCache::Bytes(id, _) => *id,
      FileSlotCache::Source(source) | FileSlotCache::Both(source, _) => {
        source.id()
      }
    }
  }
}

trait Cacheable: Clone + Sized {
  fn read(id: FileId) -> FileResult<Self>;
  fn to_cache(self, id: FileId) -> FileSlotCache;
  fn from_cache(cache: &mut FileSlotCache) -> FileResult<Self>;
  fn update_cache(cache: &mut FileSlotCache, id: FileId) -> FileResult<Self>;
}

impl Cacheable for Source {
  fn read(id: FileId) -> FileResult<Self> {
    let path = id.vpath().as_rooted_path();
    let buf =
      read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
    Ok(Source::new(id, buf))
  }

  fn to_cache(self, _: FileId) -> FileSlotCache {
    FileSlotCache::Source(self)
  }

  // There is a redundant `clone()` in both implementations.
  // However, we can't eliminate them without using `unsafe` or introducing
  // an invalid state to `FileSlotCache`.
  fn from_cache(cache: &mut FileSlotCache) -> FileResult<Self> {
    match cache {
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
        *cache = FileSlotCache::Both(source.clone(), bytes);
        Ok(source)
      }
    }
  }

  fn update_cache(cache: &mut FileSlotCache, id: FileId) -> FileResult<Self> {
    match cache {
      FileSlotCache::Source(source) => {
        let path = id.vpath().as_rooted_path();
        let buf =
          read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
        source.replace(&buf);
        Ok(source.clone())
      }
      FileSlotCache::Both(source, _) => {
        let mut source = source.clone();
        let path = id.vpath().as_rooted_path();
        let buf =
          read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
        source.replace(&buf);
        *cache = FileSlotCache::Source(source.clone());
        Ok(source)
      }
      FileSlotCache::Bytes(_, _) => {
        let result = Self::read(id)?;
        *cache = Self::to_cache(result.clone(), id);
        Ok(result)
      }
    }
  }
}

impl Cacheable for Bytes {
  fn read(id: FileId) -> FileResult<Self> {
    let path = id.vpath().as_rooted_path();
    let buf = read(path).map_err(|err| FileError::from_io(err, path))?;
    Ok(Bytes::new(buf))
  }

  fn to_cache(self, id: FileId) -> FileSlotCache {
    FileSlotCache::Bytes(id, self)
  }

  fn from_cache(cache: &mut FileSlotCache) -> FileResult<Self> {
    match cache {
      FileSlotCache::Bytes(_, bytes) | FileSlotCache::Both(_, bytes) => {
        Ok(bytes.clone())
      }
      FileSlotCache::Source(source) => {
        let bytes = Bytes::from_string(source.text().to_owned());
        *cache = FileSlotCache::Both(source.clone(), bytes.clone());
        Ok(bytes)
      }
    }
  }

  fn update_cache(cache: &mut FileSlotCache, id: FileId) -> FileResult<Self> {
    let result = Self::read(id)?;
    *cache = Self::to_cache(result.clone(), id);
    Ok(result)
  }
}
