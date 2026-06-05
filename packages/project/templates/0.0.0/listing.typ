#let listing(
  documents,
  limit: none,
  data-tags: true,
) = html.ul(class: "listing", {
  let limit = if limit == none { documents.len() } else { limit }

  for (document: doc, metadata: meta) in documents.slice(0, limit) {
    html.elem(
      "li",
      attrs: if data-tags and doc.keywords.len() > 0 {
        (data-tags: doc.keywords.join(" "))
      } else { (:) },
      {
        html.div(class: "title", {
          link(doc.path.slice(0, -"index.html".len()), doc.title)

          let meta-fields = ()
          if meta.published != none {
            meta-fields.push(html.span[#meta.published.display() 发布])
          }
          if meta.updated != none {
            meta-fields.push(html.span[#meta.updated.display() 更新])
          }
          let tags = meta.at("tags", default: ())
          if tags != () {
            if type(tags) == str {
              tags = (tags,)
            }
            meta-fields.push(html.span(
              tags
                .map(tag => html.a(
                  href: "/?tag=" + tag + "#filter",
                  "#" + tag,
                ))
                .join(),
            ))
          }
          if meta-fields.len() > 0 {
            html.div(class: "meta", meta-fields.join([ ]))
          }
        })

        if meta.excerpt != none {
          html.div(class: "excerpt", meta.excerpt)
        }
      },
    )
  }

  if documents.len() > limit {
    html.li(
      html.details({
        html.summary[展开全部]
        listing(documents.slice(limit), data-tags: data-tags)
      }),
    )
  }
})
