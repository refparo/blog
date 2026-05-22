use std::fs::{read, read_to_string};

use typst::diag::{FileError, FileResult};
use typst::foundations::Bytes;
use typst::syntax::{FileId, Source};

pub struct FileCache(Inner);

enum Inner {
  Bytes(FileId, Bytes),
  Source(Source),
  Both(Source, Bytes),
}

pub trait Cacheable: Clone + Sized {
  fn read(id: FileId) -> FileResult<Self>;
  fn to_cache(self, id: FileId) -> FileCache;
  fn from_cache(cache: &mut FileCache) -> FileResult<Self>;
}

impl Cacheable for Source {
  fn read(id: FileId) -> FileResult<Self> {
    let path = id.vpath().as_rootless_path();
    let buf =
      read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
    Ok(Source::new(id, buf))
  }

  fn to_cache(self, _: FileId) -> FileCache {
    FileCache(Inner::Source(self))
  }

  // There is a redundant `clone()` in both implementations.
  // However, we can't eliminate them without using `unsafe` or introducing
  // an invalid state to `FileSlotCache`.
  fn from_cache(cache: &mut FileCache) -> FileResult<Self> {
    match &cache.0 {
      Inner::Source(source) | Inner::Both(source, _) => Ok(source.clone()),
      Inner::Bytes(id, bytes) => {
        let bytes = bytes.clone();
        let text = bytes
          .as_str()
          .map_err(|_| FileError::InvalidUtf8)?
          .to_owned();
        let source = Source::new(*id, text);
        *cache = FileCache(Inner::Both(source.clone(), bytes));
        Ok(source)
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

  fn to_cache(self, id: FileId) -> FileCache {
    FileCache(Inner::Bytes(id, self))
  }

  fn from_cache(cache: &mut FileCache) -> FileResult<Self> {
    match &cache.0 {
      Inner::Bytes(_, bytes) | Inner::Both(_, bytes) => Ok(bytes.clone()),
      Inner::Source(source) => {
        let bytes = Bytes::from_string(source.text().to_owned());
        *cache = FileCache(Inner::Both(source.clone(), bytes.clone()));
        Ok(bytes)
      }
    }
  }
}
