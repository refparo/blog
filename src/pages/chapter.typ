#import "../components/page-metadata.typ": page-metadata
#import "../bundle.typ": with-current-document
#import "../config.typ": with-config
#import "../utils.typ": assert-type
#import "page.typ": page, query-page-by-path, setup-page-type
#import "template.typ": page-template

/// Define a chapter of a collection.
///
/// - title (str): Title of the chapter.
/// - description (content): Description of the post.
/// - published (datetime, none): Published date of the post.
/// - updated (datetime, none): Updated date of the post.
/// - outline (bool): Whether to show an outlint of the post.
/// - hidden (bool): Whether to hide the post from the listing.
/// - content (content):
/// -> content
#let chapter(
  title: none,
  description: none,
  published: none,
  updated: none,
  outline: false,
  hidden: false,
  content,
) = {
  assert-type(title, str)
  assert-type(description, (str, none))
  assert-type(published, (datetime, none))
  assert-type(updated, (datetime, none))
  assert-type(outline, bool)
  assert-type(hidden, bool)
  assert-type(content, std.content)
  with-current-document(doc => page(
    type: "chapter",
    document: doc,
    title: title,
    description: description,
    published: published,
    updated: updated,

    outline: outline,
    hidden: hidden,
    content: content,
  ))
}

#let setup-chapter(bundle) = setup-page-type(
  "chapter",
  page => with-config(config => page-template(
    title: page.title + " - " + config.title, // TODO
    author: config.author,
    tags: page.tags,
    description: page.description,
    favicon: config.favicon,
    header: {
      html.h1(page.title)

      page-metadata(page)
    },
    outline: page.outline,
    content: page.content,
    copyright: config.copyright,
    license: {
      query-page-by-path(
        page.document.path.find(regex(`^/[^/]+/`.text)) + "index.html",
      ).license
    },
    links: config.links,
  )),
  bundle,
)

// TODO 翻页按钮
