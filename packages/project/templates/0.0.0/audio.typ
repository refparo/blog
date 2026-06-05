#import "@preview/based:0.2.0": base16
#import "@preview/digestify:0.2.0": sha1

#import "outputs.typ": hoist-asset
#import "reader.typ": reader-state

#let use-audio() = doc => context if target() == "html" {
  doc
  html.style(read("audio.css"))
  html.script(type: "module", read("audio.js"))
} else {
  doc
}

#let audio(src) = context if target() == "html" {
  let reader = reader-state.get()
  let filename = src.split("/").at(-1)
  let dot-position = filename.position(".")
  let basename = filename.slice(0, dot-position)
  let extension = filename.slice(dot-position)
  let bytes = reader(src, encoding: none)
  let hash = base16.encode(sha1(bytes)).slice(0, 8)
  let path = "/assets/" + basename + "-" + hash + extension
  hoist-asset(path, bytes)
  html.audio(class: "audio-clip", src: path)
}
