use std::fs::{read, read_to_string};

use typst::diag::{FileError, FileResult};
use typst::foundations::Bytes;
use typst::syntax::{FileId, Source};

pub struct FileSlotCache(Inner);

enum Inner {
  Bytes(FileId, Bytes),
  Source(Source),
  Both(Source, Bytes),
}

impl FileSlotCache {
  pub fn id(&self) -> FileId {
    match &self.0 {
      Inner::Bytes(id, _) => *id,
      Inner::Source(source) | Inner::Both(source, _) => source.id(),
    }
  }
}

pub trait Cacheable: Clone + Sized {
  fn read(id: FileId) -> FileResult<Self>;
  fn to_cache(self, id: FileId) -> FileSlotCache;
  fn from_cache(cache: &mut FileSlotCache) -> FileResult<Self>;
  fn update_cache(cache: &mut FileSlotCache) -> FileResult<Self>;
}

impl Cacheable for Source {
  fn read(id: FileId) -> FileResult<Self> {
    let path = id.vpath().as_rootless_path();
    let buf =
      read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
    Ok(Source::new(id, buf))
  }

  fn to_cache(self, _: FileId) -> FileSlotCache {
    FileSlotCache(Inner::Source(self))
  }

  // There is a redundant `clone()` in both implementations.
  // However, we can't eliminate them without using `unsafe` or introducing
  // an invalid state to `FileSlotCache`.
  fn from_cache(cache: &mut FileSlotCache) -> FileResult<Self> {
    match &cache.0 {
      Inner::Source(source) | Inner::Both(source, _) => Ok(source.clone()),
      Inner::Bytes(id, bytes) => {
        let bytes = bytes.clone();
        let text = bytes
          .as_str()
          .map_err(|_| FileError::InvalidUtf8)?
          .to_owned();
        let source = Source::new(*id, text);
        *cache = FileSlotCache(Inner::Both(source.clone(), bytes));
        Ok(source)
      }
    }
  }

  fn update_cache(cache: &mut FileSlotCache) -> FileResult<Self> {
    let id = cache.id();
    match &mut cache.0 {
      Inner::Source(source) => {
        let path = id.vpath().as_rooted_path();
        let buf =
          read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
        source.replace(&buf);
        Ok(source.clone())
      }
      Inner::Both(source, _) => {
        let mut source = source.clone();
        let path = id.vpath().as_rooted_path();
        let buf =
          read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
        source.replace(&buf);
        *cache = FileSlotCache(Inner::Source(source.clone()));
        Ok(source)
      }
      Inner::Bytes(_, _) => {
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
    FileSlotCache(Inner::Bytes(id, self))
  }

  fn from_cache(cache: &mut FileSlotCache) -> FileResult<Self> {
    match &cache.0 {
      Inner::Bytes(_, bytes) | Inner::Both(_, bytes) => Ok(bytes.clone()),
      Inner::Source(source) => {
        let bytes = Bytes::from_string(source.text().to_owned());
        *cache = FileSlotCache(Inner::Both(source.clone(), bytes.clone()));
        Ok(bytes)
      }
    }
  }

  fn update_cache(cache: &mut FileSlotCache) -> FileResult<Self> {
    let id = cache.id();
    let result = Self::read(id)?;
    *cache = Self::to_cache(result.clone(), id);
    Ok(result)
  }
}
