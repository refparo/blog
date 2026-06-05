#import "base.typ": base
#import "post.typ": post-metadata

#let single(
  path,
  reader: none,
  title: none,
  author: (),
  published: none,
  updated: none,
  outline: false,
  hidden: false,
) = doc => context {
  let meta = (
    type: "single",
    published: published,
    updated: updated,
    hidden: hidden,
  )
  base(
    path,
    title: title,
    author: author,
    date: if updated == none { published } else { updated },
    meta: meta,
    head: {},
    body: {
      html.h1(title)

      post-metadata(meta)

      doc
    },
  )
}
