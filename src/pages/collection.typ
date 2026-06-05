#import "../components/listing.typ": listing
#import "../components/page-metadata.typ": page-metadata
#import "../bundle.typ": with-current-document
#import "../config.typ": with-config
#import "../utils.typ": assert-type
#import "page.typ": page, query-pages-by-type, setup-page-type
#import "template.typ": page-template

/// Define a collection of posts.
///
/// - title (str): Title of the collection.
/// - description (content): Description of the post.
/// - published (datetime, none): Published date of the collection introduction.
/// - updated (datetime, none): Updated date of the collection introduction.
/// - hidden (bool): Whether to hide the collection from the listing.
/// - license (content): License of the collection.
/// - content (content):
/// -> content
#let collection(
  title: none,
  description: none,
  published: none,
  updated: none,
  hidden: false,
  license: [],
  content,
) = {
  assert-type(title, str)
  assert-type(description, (str, none))
  assert-type(published, (datetime, none))
  assert-type(updated, (datetime, none))
  assert-type(hidden, bool)
  assert-type(license, std.content)
  assert-type(content, std.content)
  with-current-document(doc => {
    let chapters = query-pages-by-type("chapter").filter(it => (
      not it.hidden
        and it.document.path.starts-with(
          doc.path.slice(0, -"index.html".len()),
        )
    ))

    let update-times = (
      updated,
      ..chapters.map(it => {
        if it.updated == none {
          it.published
        } else {
          it.updated
        }
      }),
    ).filter(t => t != none)
    let updated = if update-times.len() > 0 {
      calc.max(..update-times)
    } else {
      none
    }

    page(
      type: "collection",
      document: doc,
      title: title,
      description: description,
      published: published,
      updated: updated,

      hidden: hidden,
      license: license,
      content: content,
      chapters: chapters,
    )
  })
}

#let setup-collection(bundle) = setup-page-type(
  "collection",
  page => with-config(config => page-template(
    title: page.title + " - " + config.title,
    author: config.author,
    description: page.description,
    favicon: config.favicon,
    header: {
      html.h1(page.title)

      page-metadata(page)
    },
    content: [
      #page.content

      = 目录

      #with-current-document(doc => context listing(page.chapters))
    ],
    copyright: config.copyright,
    license: page.license,
    links: config.links,
  )),
  bundle,
)
