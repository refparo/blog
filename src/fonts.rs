use std::sync::LazyLock;

use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst_kit::fonts::{FontSearcher, FontSlot, Fonts};

static FONTS: LazyLock<LazyHashFonts> =
  LazyLock::new(|| LazyHashFonts::new(FontSearcher::new().search()));

pub fn book() -> &'static LazyHash<FontBook> {
  &FONTS.book()
}

pub fn font(index: usize) -> Option<Font> {
  FONTS.fonts().get(index).and_then(|slot| slot.get())
}

// We need this wrapper until the changes in `Fonts` are published in a release.
pub struct LazyHashFonts {
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

  pub fn book(&self) -> &LazyHash<FontBook> {
    &self.book
  }

  pub fn fonts(&self) -> &[FontSlot] {
    &self.fonts
  }
}
