#let page-metadata(page) = {
  show: it => if target() == "html" {
    html.p(id: "meta", it)
  } else { it }

  let fields = ()
  if page.published != none {
    fields.push(html.time(
      datetime: page.published,
    )[#page.published.display() 发布])
  }
  if page.updated != none {
    fields.push(html.time(
      datetime: page.updated,
    )[#page.updated.display() 更新])
  }
  if page.tags != () {
    fields.push(html.span(
      page
        .tags
        .map(tag => html.a(
          href: "/?tag=" + tag + "#filter",
          "#" + tag,
        ))
        .join(" "),
    ))
  }
  if fields.len() > 0 {
    fields.join([ · ])
  }
}
