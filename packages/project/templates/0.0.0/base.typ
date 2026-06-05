#import "@preview/based:0.2.0": base16
#import "@preview/digestify:0.2.0": sha1

#import "config.typ": get-config
#import "outputs.typ": (
  define-document, document-metadata, get-output, hoist-asset, normalize-path,
  output-label,
)
#import "reader.typ": reader-state

#let base(path, reader: none, ..args, meta: (:), head: [], body: []) = {
  let path = normalize-path(path)

  show: doc => define-document(path, doc, ..args)

  document-metadata(meta)

  show figure.where(kind: table): set figure.caption(position: top)

  show footnote: it => {
    html.a(
      class: "fn-ref",
      href: "#fn-" + str(counter(footnote).get().at(0)),
      counter(footnote).display(),
    )
  }

  show image: it => {
    let path
    let asset
    if type(it.source) == str {
      let filename = it.source.split("/").at(-1)
      let dot-position = filename.position(".")
      let basename = filename.slice(0, dot-position)
      let extension = filename.slice(dot-position)
      let bytes = reader(it.source, encoding: none)
      let hash = base16.encode(sha1(bytes)).slice(0, 8)
      path = "/assets/" + basename + "-" + hash + extension
      hoist-asset(path, bytes)
    } else {
      if it.format == none {
        panic("the format of the image must be specified when passing a bytes")
      }
      let hash = base16.encode(sha1(it.source)).slice(0, 8)
      path = "/assets/" + hash + "." + it.format
      hoist-asset(path, it.source)
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
    block(html.img(src: path, ..args))
  }

  show link: it => {
    if type(it.dest) == str and it.dest.starts-with(regex("https?://")) {
      html.a(target: "_blank", href: it.dest, it.body)
    } else {
      it
    }
  }

  show par: it => {
    if it.first-line-indent != (amount: 0pt, all: false) {
      html.p(
        style: "text-indent: " + repr(it.first-line-indent.amount) + ";",
        it.body,
      )
    } else { it }
  }

  show raw.where(block: true): it => {
    show raw.line: it => {
      html.span(class: "ln", str(it.number))
      html.span(class: "cl", it.body)
    }
    it
  }

  counter(footnote).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)

  reader-state.update(_ => reader)

  let config = get-config()

  let (lang, script, region) = config.site-lang

  html.html(
    lang: lang
      + if script == auto { "" } else { "-" + script }
      + if region == none { "" } else { "-" + region },
    {
      html.head({
        html.meta(charset: "utf-8")
        html.meta(
          name: "viewport",
          content: "width=device-width, initial-scale=1, shrink-to-fit=no",
        )
        let page-title = args.named().at("title", default: none)
        html.title(
          if page-title != config.site-title { page-title + " - " } else { "" }
            + config.site-title,
        )
        if config.site-icon != none {
          let elem = get-output(config.site-icon)
          if type(elem) != content or elem.func() != asset {
            panic(
              "expected site-icon to be asset; got " + repr(config.site-icon),
            )
          }
          html.link(
            rel: "icon",
            type: "image/x-icon",
            href: normalize-path(config.site-icon),
          )
        }
        html.link(
          rel: "preload",
          href: config.style-path,
          ..("as": "style"),
        )
        html.link(
          rel: "stylesheet",
          href: config.style-path,
        )
        head
      })
      html.body({
        html.header({
          html.span(id: "breadcrumb", {
            "/"
            let split-path = path.split("/").slice(1, -1)
            for i in range(split-path.len()) {
              let path = (
                split-path.slice(0, i).map(s => "/" + s).join("")
                  + "/index.html"
              )
              let lab = output-label(path)
              let output = get-output(lab, default: none)
              if output != none {
                link(
                  output.path.slice(0, -"index.html".len()),
                  output.title + "/",
                )
              }
            }
          })
        })
        html.main(context {
          body

          let footnotes = query(selector(footnote).within(output-label(path)))
          if footnotes.len() > 0 {
            divider()

            html.ol(
              id: "footnotes",
              footnotes
                .enumerate(start: 1)
                .map(((i, it)) => html.li(id: "fn-" + str(i), {
                  it.body
                  link(it.location(), sym.arrow.l.hook)
                }))
                .join(),
            )
          }
        })
        html.footer({
          if config.comment-section != none {
            html.div(id: "comment", config.comment-section)
          }
          html.div(id: "copyright")[
            #sym.copyright #config.site-author #datetime.today().year().
            Built with #link("https://typst.app/")[Typst].
          ]
        })
      })
    },
  )

  reader-state.update(none)
}
