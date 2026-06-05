#let aside(body) = context if target() == "html" {
  html.aside(body)
} else {
  quote(block: true, body)
}

#let note(body) = context if target() == "html" {
  html.div(role: "note", body)
} else {
  quote(block: true, body)
}
