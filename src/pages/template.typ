#import "../bundle.typ": hoist-asset, with-current-document
#import "../config.typ": with-config
#import "../fonts.typ": fonts-css
#import "../utils.typ": assert-type, path-to-str
#import "page.typ": query-page-by-path

/// Hoist a fragment into the HTML head.
///
/// - key (str): Key used to deduplicate head entries. For one key, only the
///   first item is hoisted, and the rest are silently ignored.
/// - content (content): The content to hoist into the head.
/// -> content
#let hoist-head(key, content) = {
  assert-type(key, str)
  assert-type(content, std.content)
  [#metadata((key, content))<__html_hoist_head>]
}

#let hoisted-heads() = with-current-document(doc => {
  query(selector(<__html_hoist_head>).within(doc.location()))
    .dedup(key: it => it.value.at(0))
    .map(it => it.value.at(1))
    .join()
})

#let render-breadcrumb() = with-current-document(doc => {
  let split-path = doc.path.split("/").slice(1, -1)
  let items = ()
  for i in range(split-path.len()) {
    let page = query-page-by-path(
      split-path.slice(0, i).map(s => "/" + s).join("") + "/index.html",
    )
    if page != none {
      items.push(link(
        page.document.path.slice(0, -"index.html".len()),
        page.title,
      ))
    }
  }
  html.span(id: "moon", aria-label: "圆月")
  items.join(html.span(" / "))
})

#let render-outline() = with-current-document(doc => html.details({
  hoist-head(
    "outline",
    html.script(type: "module", defer: true, read("outline.js")),
  )

  html.summary(html.h2(id: "outline-label")[目录])

  let headings = query(
    selector(heading).within(
      selector(<__prose_content>).within(doc.location()),
    ),
  )
  if outline.depth != none {
    headings = headings.filter(it => it.level <= outline.depth)
  }
  html.ol(for it in headings {
    html.elem("li", attrs: (data-level: str(it.level)), link(it.location(), {
      if it.numbering != none {
        counter(heading).display(it.numbering, at: it.location())
        [ ]
      }
      it.body
    }))
  })
}))

#let prose-style(content) = {
  show <__prose_content>: it => {
    counter(heading).update(0)
    for kind in query(selector(figure).within(it.location()))
      .map(it => it.kind)
      .dedup() {
      counter(figure.where(kind: kind)).update(0)
    }
    it
  }

  set figure.caption(position: top)
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure: it => html.elem(
    "figure",
    attrs: (
      data-kind: if type(it.kind) == function { repr(it.kind) } else {
        it.kind
      },
    ),
    {
      let caption = if it.supplement != none and it.caption == none {
        html.figcaption({
          it.supplement
          if it.numbering != none {
            " "
            counter(figure.where(kind: it.kind)).display()
          }
        })
      } else { it.caption }
      // The empty line is necessary to ensure #it.body is wrapped in <p>.
      if figure.caption.position == top [
        #caption

        #it.body
      ] else [
        #it.body

        #caption
      ]
    },
  )

  show footnote: it => {
    html.a(
      class: "fn-ref",
      href: "#fn-" + str(counter(footnote).get().at(0)),
      counter(footnote).display(),
    )
  }
  show <__prose_content>: it => {
    counter(footnote).update(0)
    it
    let footnotes = query(selector(footnote).within(it.location()))
    if footnotes.len() > 0 {
      divider()

      html.ol(
        id: "footnotes",
        aria-label: "脚注",
        footnotes
          .enumerate(start: 1)
          .map(((i, it)) => html.li(id: "fn-" + str(i), {
            it.body
            // TODO 添加 aria-label: "返回正文"
            // 目前 Typst 无法做到
            link(it.location(), sym.arrow.l.hook)
          }))
          .join(),
      )
    }
  }

  show image: it => {
    assert-type(it.source, (path, bytes))
    let (path, asset) = if type(it.source) == path {
      hoist-asset(path-to-str(it.source).find(regex("[^/]+$")), read(
        it.source,
        encoding: none,
      ))
    } else {
      assert-type(it.format, str)
      hoist-asset("image." + it.format, it.source)
    }

    let measured = measure({
      set text(size: 16pt)
      it
    })
    let style = ""
    if it.width != auto {
      style += "width:" + str(measured.width / 1pt) + "px;"
    }
    if it.height != auto {
      style += "height:" + str(measured.height / 1pt) + "px;"
    }
    let args = (style: style)
    if it.alt != none { args.insert("alt", it.alt) }

    asset
    block(html.img(src: path, ..args))
  }

  show par: it => if it.first-line-indent != (amount: 0pt, all: false) {
    html.p(
      style: "text-indent: " + repr(it.first-line-indent.amount) + ";",
      it.body,
    )
  } else { it }

  show raw.where(block: true): it => {
    show raw.line: it => {
      html.span(class: "ln", aria-hidden: true, str(it.number))
      html.span(class: "cl", it.body)
    }
    it
  }

  [#content<__prose_content>]
}

#let (css-path, css-asset) = hoist-asset(
  "styles.css",
  read("../style.css") + fonts-css,
)

#let page-template(
  title: none,
  author: none,
  tags: (),
  description: none,
  favicon: none,
  breadcrumb: true,
  header: [],
  outline: false,
  content: [],
  copyright: [],
  license: [],
  links: (),
) = {
  assert-type(title, str)
  assert-type(author, str)
  assert-type(tags, (array: str))
  assert-type(description, (str, none))
  assert-type(favicon, (bytes, none))
  assert-type(breadcrumb, bool)
  assert-type(header, std.content)
  assert-type(outline, bool)
  assert-type(content, std.content)
  assert-type(copyright, std.content)
  assert-type(license, std.content)
  assert-type(links, (array: std.content))

  let lang = (
    text.lang
      + if text.script == auto { "" } else { "-" + text.script }
      + if text.region == none { "" } else { "-" + text.region }
  )

  html.html(lang: lang, {
    html.head({
      html.meta(charset: "utf-8")
      html.meta(
        name: "viewport",
        content: "width=device-width, initial-scale=1, shrink-to-fit=no",
      )
      html.title(title)
      if favicon != none {
        let (path, asset) = hoist-asset("favicon.ico", favicon)
        asset
        html.link(rel: "icon", type: "image/x-icon", href: path)
      }
      css-asset
      html.link(rel: "stylesheet", href: css-path)
      hoisted-heads()
      html.meta(name: "author", content: author)
      if tags != () {
        html.meta(name: "keywords", content: tags.join(", "))
      }
      if description != none {
        html.meta(name: "description", content: description)
      }
      // TODO link alternative feed
    })
    html.body({
      if breadcrumb {
        html.nav(
          id: "breadcrumb",
          aria-label: "面包屑导航",
          render-breadcrumb(),
        )
      }
      html.main({
        if header != [] {
          html.header(header)
        }
        if outline {
          html.nav(
            id: "outline",
            aria-labelledby: "outline-label",
            render-outline(),
          )
        }
        if content != [] {
          html.div(class: "prose", prose-style(content))
        }
      })
      html.footer({
        html.p(id: "copyright", {
          copyright
          if license != [] [ · #license]
        })
        if links != () {
          html.p(id: "links", links.join(" · "))
        }
      })
    })
  })
}
