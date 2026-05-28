use std::collections::HashMap;
use std::fs::{copy, create_dir, remove_dir_all};
use std::path::{Path, PathBuf};

use anyhow::Context;
use time::OffsetDateTime;
use typst::diag::{FileResult, SourceDiagnostic, SourceResult, Warned};
use typst::foundations::{Bytes, Datetime, Dict, Duration, Output, Repr};
use typst::syntax::{FileId, RootedPath, Source, VirtualPath};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Library, World};
use typst_html::HtmlDocument;
use typst_kit::diagnostics::termcolor::{BufferedStandardStream, ColorChoice};
use typst_kit::diagnostics::{DiagnosticFormat, DiagnosticWorld};
use walkdir::WalkDir;

use crate::cache::FileCache;
use crate::compilation::BlogCompilation;
use crate::config::{CONTENT_DIR, OUTPUT_DIR};
use crate::extract_metadata;
use crate::fonts::FONTS;

pub struct BlogCompiler {
  cache: FileCache,
  now: OffsetDateTime,
}

impl BlogCompiler {
  pub fn new() -> Self {
    Self {
      cache: FileCache::new(),
      now: OffsetDateTime::now_local().unwrap(),
    }
  }

  pub fn compile<T: Output>(
    &self,
    main: FileId,
    inputs: Dict,
  ) -> Warned<SourceResult<T>> {
    typst::compile(&BlogCompilation::new(&self.cache, main, inputs, self.now))
  }

  pub fn compile_all(&self) -> anyhow::Result<()> {
    remove_dir_all(OUTPUT_DIR)
      .with_context(|| "Failed to clear output directory")?;

    create_dir(OUTPUT_DIR)
      .with_context(|| "Failed to create output directory")?;

    let mut path_map: HashMap<FileId, (PathBuf, PathBuf)> = HashMap::new();

    for entry in WalkDir::new(CONTENT_DIR)
      .follow_links(true)
      .into_iter()
      .skip(1)
    {
      let entry = entry.with_context(|| {
        format!(
          "Error occurred while traversing the content directory '{}'",
          CONTENT_DIR
        )
      })?;
      let input_path = entry.path();
      let output_path = {
        let Ok(stripped) = input_path.strip_prefix(CONTENT_DIR) else {
          panic!(
            "WalkDir of '{}' contains an entry that isn't prefixed by '{0}'",
            CONTENT_DIR
          )
        };
        Path::new(OUTPUT_DIR).join(stripped)
      };
      match entry.file_type() {
        it if it.is_dir() => {
          create_dir(&output_path).with_context(|| {
            format!("Failed to create directory '{}'", output_path.display())
          })?;
        }
        it if it.is_file() => {
          if input_path.extension() == Some("typ".as_ref()) {
            let mut output_path = output_path;
            if input_path.file_name().expect("should be normal file")
              == "index.typ"
            {
              output_path.set_extension("html");
            } else {
              output_path.set_extension("");
              create_dir(&output_path).with_context(|| format!(
                "File '{}' and directory '{}' exists simultaneously. Only one of them is allowed.",
                input_path.display(),
                input_path.with_extension("").display()
              ))?;
              output_path.push("index.html");
            }
            path_map.insert(
              FileId::new(RootedPath::new(
                typst::syntax::VirtualRoot::Project,
                VirtualPath::new(input_path.to_str().with_context(|| {
                  format!(
                    "The path '{}' isn't valid unicode",
                    input_path.display()
                  )
                })?)
                .expect("should always be valid virtual path"),
              )),
              (entry.into_path(), output_path),
            );
          } else {
            copy(input_path, output_path).with_context(|| {
              format!("Failed to copy asset file '{}'", input_path.display())
            })?;
          }
        }
        _ => {
          return Err(anyhow::anyhow!(
            "Unexpected file type: {:?}",
            entry.file_type()
          ));
        }
      }
    }

    let mut diagnostics: Vec<SourceDiagnostic> = Vec::new();

    let mut metadata_map: HashMap<FileId, Dict> = HashMap::new();
    for (&file_id, (input_path, _)) in path_map.iter() {
      println!("compiling file '{}' for metadata", input_path.display());
      let Warned { output, warnings } =
        self.compile::<HtmlDocument>(file_id, Dict::new());
      diagnostics.extend(warnings.into_iter().filter(|warning| {
        warning.message.as_str()
          != "html export is under active development and incomplete"
      }));
      match output {
        Ok(output) => {
          metadata_map.insert(file_id, extract_metadata(&output)?);
          println!(
            "got metadata from file '{}': {}",
            input_path.display(),
            metadata_map[&file_id].repr()
          );
        }
        Err(errors) => {
          diagnostics.extend(errors.into_iter());
        }
      }
    }

    for (_file_id, (input_path, output_path)) in path_map {
      println!(
        "will compile file '{}' => '{}'",
        input_path.display(),
        output_path.display()
      );
    }

    if !diagnostics.is_empty() {
      typst_kit::diagnostics::emit(
        &mut BufferedStandardStream::stdout(ColorChoice::Auto),
        self,
        &diagnostics,
        DiagnosticFormat::Human,
      )?;
    }

    Ok(())
  }
}

impl World for BlogCompiler {
  fn library(&self) -> &LazyHash<Library> {
    unimplemented!()
  }

  fn book(&self) -> &LazyHash<FontBook> {
    FONTS.book()
  }

  fn main(&self) -> FileId {
    unimplemented!()
  }

  fn source(&self, id: FileId) -> FileResult<Source> {
    self.cache.access(id)
  }

  fn file(&self, id: FileId) -> FileResult<Bytes> {
    self.cache.access(id)
  }

  fn font(&self, index: usize) -> Option<Font> {
    FONTS.font(index)
  }

  fn today(&self, _: Option<Duration>) -> Option<Datetime> {
    unimplemented!()
  }
}

impl DiagnosticWorld for BlogCompiler {
  fn name(&self, id: FileId) -> String {
    id.get().vpath().get_without_slash().to_owned()
  }
}
