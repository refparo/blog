#import "../components/page-metadata.typ": page-metadata
#import "../bundle.typ": with-current-document
#import "../config.typ": with-config
#import "../utils.typ": assert-type
#import "page.typ": page, setup-page-type
#import "template.typ": page-template

/// Define a post.
///
/// - title (str): Title of the post.
/// - description (content): Description of the post.
/// - tags (array): Tags of the post.
/// - published (datetime, none): Published date of the post.
/// - updated (datetime, none): Updated date of the post.
/// - outline (bool): Whether to show an outlint of the post.
/// - hidden (bool): Whether to hide the post from the listing.
/// - license (content): License of the post.
/// - content (content):
/// -> content
#let post(
  title: none,
  tags: (),
  description: none,
  published: none,
  updated: none,
  outline: false,
  hidden: false,
  license: [],
  content,
) = {
  assert-type(title, str)
  assert-type(description, (str, none))
  assert-type(tags, ((array: str), str))
  assert-type(published, (datetime, none))
  assert-type(updated, (datetime, none))
  assert-type(outline, bool)
  assert-type(hidden, bool)
  assert-type(license, std.content)
  assert-type(content, std.content)
  if type(tags) == str {
    tags = (tags,)
  }
  with-current-document(doc => page(
    type: "post",
    document: doc,
    title: title,
    tags: tags,
    description: description,
    published: published,
    updated: updated,

    outline: outline,
    hidden: hidden,
    license: license,
    content: content,
  ))
}

#let setup-post(bundle) = setup-page-type(
  "post",
  page => with-config(config => page-template(
    title: page.title + " - " + config.title,
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
    license: page.license,
    links: config.links,
  )),
  bundle,
)
