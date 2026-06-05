#import "utils.typ": assert-type

#let redirect(src, dest, code: 301) = {
  assert-type(src, str)
  assert-type(dest, str)
  assert-type(code, (301, 302, 200))
  [#metadata((src: src, dest: dest, code: code))<__alias>]
}

#let setup-redirect() = context {
  let aliases = query(<__alias>)
  if aliases.len() > 0 {
    asset(
      "/_redirects",
      aliases
        .map(elem => {
          let (src, dest, code) = elem.value
          src + " " + dest + " " + str(code)
        })
        .join("\n"),
    )
  }
}
