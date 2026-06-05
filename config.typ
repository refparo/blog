#import "@project/templates:0.0.0": configure, define-asset

#let initialize = doc => {
  define-asset(
    "/favicon.ico",
    read("/assets/favicon.ico", encoding: none),
  )

  configure(
    site-title: "浸月之海",
    site-author: "Paro",
    site-icon: "/favicon.ico",
    comment-section: [
      欢迎前往 #link("https://github.com/refparo/blog/discussions")[GitHub Discussions] 发表评论，或者通过#link("mailto:ref.paro@outlook.com")[邮件]与我交流。
    ],
  )

  set text(lang: "zh", script: "hans", region: "cn")

  set raw(
    syntaxes: (
      // from https://github.com/buzden/sublime-syntax-idris2/blob/4d8eb35a38254d422030e77b4933530008dd3c6e/idris2.sublime-syntax
      "assets/idris2.sublime-syntax",
    ),
    // from https://github.com/SublimeText/LegacyColorSchemes/blob/6774cf43fb63b5304057a1295de2606bce1da7ce/Solarized%20(Dark).tmTheme
    theme: "assets/Solarized (Dark).tmTheme",
  )

  set footnote(numbering: "[1]")

  doc
}
