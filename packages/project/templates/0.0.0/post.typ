#import "config.typ": get-config
#import "base.typ": base

#let post-metadata(meta) = {
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
    html.div(id: "meta", meta-fields.join(
      html.span(class: "divider") + [ ],
    ))
  }
}


/// Define a blog post.
///
/// - path (str): Path of the post.
/// - title (str, none): Title of the post.
/// - author (str, array, none): Author(s) of the post.
/// - tags (array): Tags of the post.
/// - published (datetime, none): Published date of the post.
/// - updated (datetime, none): Updated date of the post.
/// - excerpt (content): An excerpt of the post.
/// -> content
#let post(
  path,
  reader: none,
  title: none,
  author: (),
  tags: (),
  published: none,
  updated: none,
  outline: false,
  hidden: false,
  excerpt: none,
) = doc => context {
  let config = get-config()
  let meta = (
    type: "post",
    tags: tags,
    published: published,
    updated: updated,
    hidden: hidden,
    excerpt: excerpt,
  )
  base(
    path,
    reader: reader,
    title: title,
    author: if author == () { config.site-author } else { author },
    keywords: tags,
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
