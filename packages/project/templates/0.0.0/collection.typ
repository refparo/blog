#import "config.typ": get-config
#import "outputs.typ": all-documents, normalize-path
#import "base.typ": base
#import "post.typ": post-metadata
#import "listing.typ": listing

#let collection(
  path,
  reader: none,
  title: none,
  author: (),
  published: none,
  updated: none,
  outline: false,
  hidden: false,
  excerpt: none,
) = doc => context {
  let normalized-path = normalize-path(path)

  let chapters = all-documents()
    .filter(it => (
      it.metadata.type == "chapter"
        and not it.metadata.hidden
        and it.document.path.starts-with(path)
        and it.document.path != normalized-path
    ))
    .sorted(key: it => it.document.path.slice(0, -"index.html".len()))

  let update-times = (
    updated,
    ..chapters.map(it => {
      if it.metadata.updated == none {
        it.metadata.published
      } else {
        it.metadata.updated
      }
    }),
  ).filter(t => t != none)
  let updated = if update-times.len() > 0 {
    calc.max(..update-times)
  } else {
    none
  }

  let config = get-config()
  let meta = (
    type: "collection",
    published: published,
    updated: updated,
    hidden: hidden,
    excerpt: excerpt,
  )
  base(
    path,
    title: title,
    author: if author == () { config.site-author } else { author },
    keywords: title,
    date: if updated == none { published } else { updated },
    meta: meta,
    head: [],
    body: {
      html.h1(title)

      post-metadata(meta)

      doc

      html.h2[目录]
      listing(chapters, data-tags: false)
    },
  )
}

#let chapter(
  path,
  reader: none,
  title: none,
  author: (),
  published: none,
  updated: none,
  outline: false,
  hidden: false,
  excerpt: none,
) = doc => context {
  let config = get-config()
  let meta = (
    type: "chapter",
    published: published,
    updated: updated,
    hidden: hidden,
    excerpt: excerpt,
  )
  let parent = all-documents().find(it => path.starts-with(it.document.path))
  base(
    path,
    reader: reader,
    title: title,
    author: if author == () { config.site-author } else { author },
    keywords: if parent != none { parent.document.title } else { () },
    date: if updated == none { published } else { updated },
    meta: meta,
    head: [],
    body: {
      html.h1(title)

      post-metadata(meta)

      doc
    },
  )
}
