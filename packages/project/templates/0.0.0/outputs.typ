#import "private.typ": private-label, private-state, sentinel-value

#let metadata-label = private-label("metadata")
#let hoisted-asset-state = private-state("hoisted-asset", (:))
#let this-document-state = private-state("current-document")

/// Normalizes a path. The input path is supposed to look like a permalink, and
/// the result would be a absolute path to the final output file.
///
/// Specifically, the input path is normalized according to the following rules:
///
/// - If the input path starts without a slash, a slash is prepended.
/// - If the input path ends with a slash, `index.html` is appended.
/// - If the input file name does not contain a file extension, `index.html` is
///   appended.
/// - If the extension of the input file name is `html`, the extension is removed, and `index.html` is appended.
///
/// For example:
///
/// #example(`
///   #assert.eq(
///     normalize-path("posts/some-article"),
///     "/posts/some-article/index.html"
///   )
///   #assert.eq(
///     normalize-path("/posts/some-article/"),
///     "/posts/some-article/index.html"
///   )
///   #assert.eq(
///     normalize-path("/posts/some-article/index.html"),
///     "/posts/some-article/index.html"
///   )
///   #assert.eq(
///     normalize-path("/posts/some-article/some-page.html"),
///     "/posts/some-article/some-page/some-page.html"
///   )
///   #assert.eq(
///     normalize-path("/posts/some-article/some-pdf.pdf"),
///     "/posts/some-article/some-pdf.pdf"
///   )
/// `)
///
/// - path (str): The input path.
/// -> str
#let normalize-path(path) = {
  if not path.starts-with("/") {
    path = "/" + path
  }
  if path.ends-with("/") {
    path + "index.html"
  } else if not path.split("/").last().contains(".") {
    path + "/index.html"
  } else {
    path
  }
}

/// Get the label for an output.
///
/// - path (str): The path of the output.
/// -> label
#let output-label(path) = private-label("output:" + normalize-path(path))

#let define-output(output) = {
  if type(output) != content {
    panic("output must be content; got " + str(type(output)))
  }
  if output.func() not in (document, asset) {
    panic("output must be document or asset; got " + repr(output))
  }
  [
    #output
    #output-label(output.path)
  ]
}

/// Define an asset.
///
/// This function must only be called at the top level of a bundle. You can use
/// `output-label(path)` to reference an asset defined with this function.
///
/// - path (str)
/// - data (bytes, str)
/// -> content
#let define-asset(path, data) = define-output(asset(path, data))

#let hoist-asset(path, data) = {
  hoisted-asset-state.update(assets => {
    if path not in assets {
      assets.insert(path, define-asset(path, data))
    }
    assets
  })
}

#let define-hoisted-assets() = context {
  hoisted-asset-state.final().values().join()
}

/// Define a document.
///
/// In addition to a simple combination of `define-output` and `document`, this
/// function does two extra things:
///
/// - Normalizes the path with `normalize-path`.
/// - Sets up an internal state, so that `this-document` can work correctly.
///
/// This function must only be called at the top level of a bundle. You can use
/// `document-label(path)` to reference a document defined with this function.
///
/// - path (str): The path of the document.
/// - body (content): The content of the document.
/// - args (arguments): Other arguments passed to `document`.
/// -> content
#let define-document(path, body, ..args) = {
  let normalized-path = normalize-path(path)
  define-output(document(normalized-path, ..args, {
    this-document-state.update(normalized-path)
    body
    this-document-state.update(none)
  }))
}

/// Gets the label of the current document.
///
/// This function is contextual, and only works inside documents defined with
/// `define-document`.
///
/// - no-arguments ():
/// -> label
#let this-document() = {
  let path = this-document-state.get()
  if path == none {
    panic(
      "`this-document` must be used inside a document defined with `define-document`",
    )
  }
  output-label(path)
}

/// Attaches metadata to a document.
///
/// This function must be called inside the body of a document, and only called
/// at most once.
///
/// - value (any): The metadata value.
/// -> content
#let document-metadata(value) = [
  #metadata(value)
  #metadata-label
]

/// Returns the output at the given path or label.
///
/// - path-or-label (str, label): The path or label of the output.
/// - default (any): The default value to return if no output is found.
/// -> content
#let get-output(path-or-label, default: sentinel-value) = {
  let lab = if type(path-or-label) == label {
    path-or-label
  } else {
    output-label(path-or-label)
  }
  let doc = query(lab).first(default: none)
  if doc == none {
    if default != sentinel-value {
      return default
    }
    panic("no document found at path `" + path + "`")
  }
  doc
}

/// Returns the metadata of the given document.
///
/// - doc (content, str, label): The document or path/label of the document.
/// - default (any): The default value to return if no document is found.
/// -> any
#let get-metadata(doc, default: sentinel-value) = {
  let doc = if type(doc) == content {
    doc
  } else {
    let doc = get-output(doc, default: none)
    if doc == none {
      if default != sentinel-value {
        return default
      }
      panic("no document found at path `" + path + "`")
    }
    doc
  }
  if doc.func() != document {
    panic("the output found at path `" + path + "` is not a document")
  }
  let (meta, ..rest) = query(selector(metadata-label).within(doc.location()))
  if rest.len() > 0 {
    panic("`document-metadata` must only be called once per document")
  }
  meta.value
}

/// Returns all documents and their metadata. This function is contextual.
///
/// - no-arguments ():
/// -> array
#let all-documents() = {
  let result = ()
  for doc in query(document) {
    let (meta, ..rest) = query(selector(metadata-label).within(doc.location()))
    if rest.len() > 0 {
      panic("`document-metadata` must only be called once per document")
    }
    result.push((document: doc, metadata: meta.value))
  }
  result
}
