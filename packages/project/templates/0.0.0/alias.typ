#import "private.typ": private-label
#import "outputs.typ": define-asset, get-output

#let aliases-label = private-label("aliases")

#let alias(src, dest) = context [
  #metadata((src: src, dest: dest))
  #aliases-label
]

#let define-aliases() = context {
  let aliases = query(aliases-label)
  if aliases.len() > 0 {
    define-asset(
      "/_redirects",
      aliases
        .map(elem => {
          let (src, dest) = elem.value
          src + " " + dest + " 301"
        })
        .join("\n"),
    )
  }
}
