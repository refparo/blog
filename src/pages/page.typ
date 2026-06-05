#import "../utils.typ": assert-type

#let page(
  type: none,
  document: none,
  title: none,
  tags: (),
  description: none,
  published: none,
  updated: none,
  ..extra,
) = {
  assert-type(type, str)
  assert-type(document, (content: std.document))
  assert-type(title, str)
  assert-type(description, (str, none))
  assert-type(tags, (array: str))
  assert-type(published, (datetime, none))
  assert-type(updated, (datetime, none))
  assert.eq(extra.pos(), ())

  let data = metadata((
    type: type,
    document: document,
    title: title,
    description: description,
    tags: tags,
    published: published,
    updated: updated,
    ..extra.named(),
  ))

  [#data#label("__page:" + type)]
  [#data#label("__page:path:" + document.path)]
}

#let query-page-by-path(path) = {
  assert-type(path, str)
  let meta = query(selector(label("__page:path:" + path))).first(default: none)
  if meta == none { return none }
  meta.value
}

#let query-pages-by-type(type) = {
  assert-type(type, str)
  query(label("__page:" + type)).map(it => it.value)
}

#let setup-page-type(type, func, bundle) = {
  show label("__page:" + type): it => func(it.value)
  bundle
}
