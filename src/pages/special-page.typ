#import "../bundle.typ": with-current-document
#import "../config.typ": with-config
#import "../utils.typ": assert-type
#import "page.typ": page, setup-page-type
#import "template.typ": page-template

/// Define a special page
///
/// - updated (datetime, none): Updated date of the special page
/// - content (content):
/// -> content
#let special-page(
  title: none,
  description: none,
  updated: none,
  header: [],
  content,
) = {
  assert-type(title, str)
  assert-type(description, (str, none))
  assert-type(updated, (datetime, none))
  assert-type(header, std.content)
  assert-type(content, std.content)
  with-config(config => with-current-document(doc => page(
    type: "special-page",
    document: doc,
    title: title,
    description: description,
    updated: updated,
    header: header,

    content: content,
  )))
}

#let setup-special-page(bundle) = setup-page-type(
  "special-page",
  page => with-config(config => page-template(
    title: page.title,
    author: config.author,
    description: page.description,
    favicon: config.favicon,
    breadcrumb: false,
    header: page.header,
    content: page.content,
    copyright: config.copyright,
    links: config.links,
  )),
  bundle,
)
