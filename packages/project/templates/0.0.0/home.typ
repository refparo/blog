#import "config.typ": get-config
#import "outputs.typ": all-documents
#import "private.typ": private-label
#import "base.typ": base
#import "listing.typ": listing

/// Define the home page.
///
/// - updated (datetime, none): Update time of the home page.
/// -> content
#let home(reader: none, updated: none) = doc => context {
  let config = get-config()
  base(
    "/",
    reader: reader,
    title: config.site-title,
    author: config.site-author,
    date: updated,
    meta: (type: "home", updated: updated),
    head: [],
    body: {
      html.h1(config.site-title)

      doc
    },
  )
}

#let post-listing-label = private-label("post-listing")

#let post-listing-location() = locate(post-listing-label)

#let post-listing() = {
  context {
    html.h2(id: "filter-container")[
      文章
      #html.div(id: "filter", html.noscript[
        需要启用 JavaScript 才能按标签筛选，当前已显示完整列表。
      ]) #post-listing-label
    ]

    let posts = all-documents()
      .filter(it => it.metadata.type == "post" and not it.metadata.hidden)
      .sorted(key: it => it.metadata.published)
      .rev()

    listing(posts, limit: 5)

    html.script(type: "module", read("listing.js"))
  }

  context {
    html.h2[合辑]

    let posts = all-documents()
      .filter(it => (
        it.metadata.type == "collection" and not it.metadata.hidden
      ))
      .sorted(key: it => if it.metadata.updated != none {
        it.metadata.updated
      } else {
        it.metadata.published
      })
      .rev()

    listing(posts)
  }
}
