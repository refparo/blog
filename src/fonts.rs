use std::sync::LazyLock;

use typst_kit::fonts::{FontStore, system};

pub static FONTS: LazyLock<FontStore> = LazyLock::new(|| {
  let mut store = FontStore::new();
  store.extend(system());
  store
});
