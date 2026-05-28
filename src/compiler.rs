use std::collections::HashMap;
use std::fs::{copy, create_dir, remove_dir_all};
use std::path::{Path, PathBuf};

use anyhow::Context;
use time::OffsetDateTime;
use typst::Document;
use typst::diag::{SourceResult, Warned};
use typst::foundations::Dict;
use typst::syntax::FileId;
use walkdir::WalkDir;

use crate::cache::FileCache;
use crate::compilation::BlogCompilation;
use crate::config::{CONTENT_DIR, OUTPUT_DIR};

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

  pub fn compile<D: Document>(
    &self,
    main: FileId,
    inputs: Dict,
  ) -> Warned<SourceResult<D>> {
    typst::compile(&BlogCompilation::new(&self.cache, main, inputs, self.now))
  }

  pub fn compile_all(&self) -> anyhow::Result<()> {
    remove_dir_all(OUTPUT_DIR)
      .with_context(|| "Failed to clear output directory")?;

    create_dir(OUTPUT_DIR)
      .with_context(|| "Failed to create output directory")?;

    let mut content_files: HashMap<PathBuf, PathBuf> = HashMap::new();

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
        let Ok(path) = input_path.strip_prefix(CONTENT_DIR) else {
          panic!(
            "WalkDir of '{}' contains an entry that isn't prefixed by '{0}'",
            CONTENT_DIR
          )
        };
        Path::new(OUTPUT_DIR).join(path)
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
            content_files.insert(entry.into_path(), output_path);
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

    for input_path in content_files.keys() {
      println!("will compile file '{}' for metadata", input_path.display());
    }

    for (input_path, output_path) in content_files {
      println!(
        "will compile file '{}' => '{}'",
        input_path.display(),
        output_path.display()
      );
    }

    Ok(())
  }
}
