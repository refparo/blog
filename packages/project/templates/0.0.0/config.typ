#import "@preview/based:0.2.0": base16
#import "@preview/digestify:0.2.0": sha1

#import "private.typ": private-state
#import "outputs.typ": define-asset, define-hoisted-assets
#import "alias.typ": define-aliases

#let config-state = private-state("config")

/// Configures the templates.
///
/// - site-title (str, none): The title of the site.
/// - site-author (str, array, none): The author(s) of the site.
/// - site-icon (str, none): The path to the site icon. The icon itself should
///   be defined as an asset. (See `define-asset`)
/// -> content
#let configure(
  site-title: none,
  site-author: (),
  site-icon: none,
  site-lang: (lang: "zh", script: auto, region: "CN"),
  comment-section: none,
) = {
  let style = read("style.css", encoding: none)
  let hash = base16.encode(sha1(style)).slice(0, 8)
  let style-path = "/assets/style-" + hash + ".css"

  config-state.update((
    site-title: site-title,
    site-author: site-author,
    site-icon: site-icon,
    site-lang: site-lang,
    comment-section: comment-section,
    style-path: style-path,
  ))

  define-asset(style-path, style)

  define-hoisted-assets()

  define-asset("/_headers", read("_headers"))

  define-aliases()
}

#let get-config() = {
  let config = config-state.get()
  if config == none {
    panic(
      "config is not initialized. please call `configure` at the beginning of the bundle",
    )
  }
  config
}
