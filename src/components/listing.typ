#import "../pages/page.typ": query-pages-by-type
#import "../pages/template.typ": hoist-head
#import "../utils.typ": assert-type

#let listing(
  pages,
  limit: none,
  tags: false,
) = html.ul(class: "listing", {
  assert-type(pages, array)
  assert-type(limit, (int, none))
  assert-type(tags, bool)

  limit = if limit == none { pages.len() } else { limit }

  for page in pages.slice(0, limit) {
    html.elem(
      "li",
      attrs: if tags and page.tags.len() > 0 {
        (data-tags: page.tags.join(" "))
      } else { (:) },
      {
        html.a(
          class: "title",
          href: page.document.path.trim("index.html", at: end, repeat: false),
          page.title,
        )

        let meta-fields = ()
        if page.published != none {
          meta-fields.push(html.time(
            datetime: page.published,
          )[#page.published.display() 发布])
        }
        if page.updated != none {
          meta-fields.push(html.time(
            datetime: page.updated,
          )[#page.updated.display() 更新])
        }
        if tags and page.tags != () {
          meta-fields.push(html.span(
            page
              .tags
              .map(tag => html.a(
                href: "/?tag=" + tag + "#filter",
                "#" + tag,
              ))
              .join(" "),
          ))
        }
        if meta-fields.len() > 0 {
          html.div(class: "meta", meta-fields.join([ ]))
        }

        if page.description != none {
          html.div(class: "description", page.description)
        }
      },
    )
  }

  if pages.len() > limit {
    html.li(
      html.details({
        html.summary[展开全部]
        listing(pages.slice(limit), tags: tags)
      }),
    )
  }
})

#let posts-listing() = context {
  html.div(id: "filter-container")[
    = 文章
    #html.div(id: "filter", html.noscript[
      需要启用 JavaScript 才能按标签筛选，当前已显示完整列表。
    ])
  ]

  let posts = query-pages-by-type("post")
    .filter(it => not it.hidden)
    .sorted(key: it => it.published)
    .rev()

  listing(posts, limit: 5, tags: true)

  hoist-head("listing", html.script(
    type: "module",
    defer: true,
    read("listing.js"),
  ))
}

#let collections-listing() = context {
  [= 合辑]

  let collections = query-pages-by-type("collection")
    .filter(it => not it.hidden)
    .sorted(key: it => if it.updated != none {
      it.updated
    } else {
      it.published
    })
    .rev()

  listing(collections)
}
