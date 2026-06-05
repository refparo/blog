#import "@preview/based:0.2.0": base32
#import "@preview/digestify:0.2.0": sha1

#import "cloudflare.typ": redirect
#import "utils.typ": assert-type

/// Hoist an asset into the bundle. Returns a tuple of the asset path and the
/// hidden content to be put into text.
///
/// - name (str): The file name of the asset to make the path more human-
///   friendly. It must be safe for URL and file names.
/// - data (str, bytes): Raw data.
/// -> array
#let hoist-asset(name, data) = {
  assert-type(name, str)
  assert-type(data, (str, bytes))
  let dot-position = name.position(".")
  let basename = name.slice(0, dot-position)
  let extension = name.slice(dot-position)
  let hash = base32.encode(sha1(bytes(data))).slice(0, 8)
  let path = "/assets/" + basename + "-" + hash + extension
  (path, [#metadata(asset(path, data))<__bundle_hoist_asset>])
}

#let setup-hoist-asset() = context {
  query(<__bundle_hoist_asset>)
    .dedup(key: it => it.value.path)
    .map(it => it.value)
    .join()
}

/// Uses the current document.
///
/// - func (function): A function that accepts the current document as its only
///   parameter
/// -> content
#let with-current-document(func) = {
  assert-type(func, function)
  [#metadata(func)<__with_current_document>]
}

#let setup-with-current-document(bundle) = {
  show document: doc => {
    show <__with_current_document>: it => (it.value)(doc)
    doc
  }
  bundle
}

/// Get the canonical permalink for a page from its source path.
///
/// - source (str): Source path of the page.
/// -> str
#let permalink(source) = {
  assert-type(source, str)
  assert(source.starts-with("/content/"))
  let source = source.slice("/content".len())
  let source = source.trim(
    regex("/posts|/collections"),
    at: start,
    repeat: false,
  )
  if source.ends-with("index.typ") {
    source.slice(0, -"index.typ".len())
  } else {
    source.slice(0, -".typ".len()) + "/"
  }
}

/// Include a Typst source as a document.
///
/// - source (str): The source path
/// - includer (function): A custom include function
/// -> content
#let include-document(
  source,
  path: none,
  includer: p => include p,
  aliases: (),
) = {
  assert-type(source, str)
  assert-type(path, (str, none))
  assert-type(includer, function)
  assert-type(aliases, (str, (array: str)))
  assert(source.starts-with("/"))
  if path == none {
    path = permalink(source) + "index.html"
  }
  let permalink = path.trim("index.html", at: end, repeat: false)
  if type(aliases) == str {
    aliases = (aliases,)
  }
  for alias in aliases {
    redirect(alias, permalink)
  }
  show <__with_source_path>: it => (it.value)(source)
  document(path, includer(source))
}

/// Uses current source path.
///
/// - func (function): A function that accepts the current source path as its
///   only parameter
/// -> content
#let with-source-path(func) = {
  assert-type(func, function)
  [#metadata(func)<__with_source_path>]
}
