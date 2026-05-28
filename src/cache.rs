use std::collections::HashMap;
use std::fs::{read, read_to_string};
use std::sync::Mutex;

use typst::diag::{FileError, FileResult};
use typst::foundations::Bytes;
use typst::syntax::{FileId, Source};

pub struct FileCache<S = FileCacheSlot>(Mutex<HashMap<FileId, S>>);

impl<S> FileCache<S> {
  pub fn new() -> Self {
    Self(Mutex::new(HashMap::new()))
  }

  pub fn access<T>(&self, id: FileId) -> FileResult<T>
  where
    S: AsMut<FileCacheSlot> + From<FileCacheSlot>,
    T: Cacheable,
  {
    let cache = &self.0;
    let mut files = cache.lock().unwrap();
    if let Some(file) = files.get_mut(&id) {
      Cacheable::from_slot(file.as_mut())
    } else {
      // I think it's better to take the risk of duplicating reads
      // rather than making everyone else wait for this read to finish.
      // Benchmarking also shows that even in serialized cases,
      // releasing the lock and re-acquiring after the read finishes is faster
      // than keeping the lock for the duration. (Why?)
      drop(files);
      let result = <T as Cacheable>::read(id)?;
      use std::collections::hash_map::Entry;
      match cache.lock().unwrap().entry(id) {
        Entry::Occupied(entry) => {
          Cacheable::from_slot(entry.into_mut().as_mut())
        }
        Entry::Vacant(entry) => {
          entry.insert(result.clone().into_slot(id).into());
          Ok(result)
        }
      }
    }
  }
}

pub struct FileCacheSlot(Inner);

enum Inner {
  Bytes(FileId, Bytes),
  Source(Source),
  Both(Source, Bytes),
}

impl AsMut<FileCacheSlot> for FileCacheSlot {
  fn as_mut(&mut self) -> &mut FileCacheSlot {
    self
  }
}

pub trait Cacheable: Clone + Sized {
  fn read(id: FileId) -> FileResult<Self>;
  fn into_slot(self, id: FileId) -> FileCacheSlot;
  fn from_slot(cache: &mut FileCacheSlot) -> FileResult<Self>;
}

impl Cacheable for Source {
  fn read(id: FileId) -> FileResult<Self> {
    let path = id.vpath().as_rootless_path();
    let buf =
      read_to_string(path).map_err(|err| FileError::from_io(err, path))?;
    Ok(Source::new(id, buf))
  }

  fn into_slot(self, _: FileId) -> FileCacheSlot {
    FileCacheSlot(Inner::Source(self))
  }

  // There is a redundant `clone()` in both implementations.
  // However, we can't eliminate them without using `unsafe` or introducing
  // an invalid state to `FileSlotCache`.
  fn from_slot(cache: &mut FileCacheSlot) -> FileResult<Self> {
    match &cache.0 {
      Inner::Source(source) | Inner::Both(source, _) => Ok(source.clone()),
      Inner::Bytes(id, bytes) => {
        let bytes = bytes.clone();
        let text = bytes
          .as_str()
          .map_err(|_| FileError::InvalidUtf8)?
          .to_owned();
        let source = Source::new(*id, text);
        *cache = FileCacheSlot(Inner::Both(source.clone(), bytes));
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

  fn into_slot(self, id: FileId) -> FileCacheSlot {
    FileCacheSlot(Inner::Bytes(id, self))
  }

  fn from_slot(cache: &mut FileCacheSlot) -> FileResult<Self> {
    match &cache.0 {
      Inner::Bytes(_, bytes) | Inner::Both(_, bytes) => Ok(bytes.clone()),
      Inner::Source(source) => {
        let bytes = Bytes::from_string(source.text().to_owned());
        *cache = FileCacheSlot(Inner::Both(source.clone(), bytes.clone()));
        Ok(bytes)
      }
    }
  }
}
