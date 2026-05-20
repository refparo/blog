#let post(title: none, tags: ()) = doc => [
  #set document(
    title: title,
    author: "Paro",
    keywords: tags,
  )
  #metadata((
    title: title,
    tags: tags,
  )) <metadata>
  #if sys.inputs.at("metadata-only", default: none) == none {
    context if target() == "html" [
      #html.html[
        #html.head[
          #html.title(title)
        ]
        #html.body(doc)
      ]
    ] else if target() == "paged" {
      doc
    } else {
      panic("unsupport target: " + target())
    }
  }
]
