#import "../pages/template.typ": hoist-head
#import "../bundle.typ": hoist-asset
#import "../utils.typ": assert-type, path-to-str

#let audio-head = hoist-head("audio", {
  html.style(read("audio.css"))
  html.script(type: "module", read("audio.js"))
})

/// An audio clip.
///
/// - source (path, str): Path to the audio file.
/// - path-fn (function): Function to convert string to path.
/// -> content
#let audio(source, path-fn: path) = {
  assert-type(source, (path, str))
  assert-type(path-fn, function)
  source = path-fn(source)
  context if target() == "html" {
    let path-str = path-to-str(source)
    let filename = path-str.split("/").at(-1)
    let (asset-path, asset) = hoist-asset(
      filename,
      read(source, encoding: none),
    )
    audio-head
    asset
    html.audio(class: "audio-clip", src: asset-path)
    html.button(aria-label: "播放音频", emoji.speaker.waves)
  } else {
    panic("unimplemented")
  }
}
