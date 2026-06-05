#let use-hyperfic() = doc => context if target() == "html" {
  html.style(read("hyperfic.css"))
  doc
} else {
  doc
}

#let hyperfic-page(ending: false, body, ..next) = {
  let links = next.pos().map(((label, target)) => link(label, target))
  context if target() == "html" {
    html.div(
      class: "subgrid hyperfic-page"
        + if ending { " hyperfic-ending" } else { "" },
      {
        body
        for link in links [- #link]
      },
    )
  } else {
    for link in links [- #link]
    pagebreak()
  }
}
