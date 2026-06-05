#import "bundle.typ": hoist-asset

#let fonts = (
  (
    font-face: (
      font-family: "'Source Han Serif VF'",
      font-weight: "400 700",
    ),
    webfont: "/fonts/subsets/SourceHanSerif-VF.woff2",
    local: (
      "'Source Han Serif SC VF Regular'",
      "'Source Han Serif SC VF Bold'",
    ),
  ),
  (
    font-face: (
      font-family: "'Source Han Sans VF'",
      font-weight: "400 700",
    ),
    webfont: "/fonts/subsets/SourceHanSans-VF.woff2",
    local: (
      "'Source Han Sans SC VF Regular'",
      "'Source Han Sans SC VF Medium'",
      "'Source Han Sans SC VF Bold'",
    ),
  ),
  (
    font-face: (
      font-family: "'Source Serif VF'",
      font-weight: "200 900",
      size-adjust: "105%",
    ),
    webfont: "/fonts/subsets/SourceSerif4Variable-Roman.woff2",
    local: "'Source Serif 4 Variable'",
  ),
  (
    font-face: (
      font-family: "'Source Serif VF'",
      font-weight: "200 900",
      font-style: "italic",
      size-adjust: "105%",
    ),
    webfont: "/fonts/subsets/SourceSerif4Variable-Italic.woff2",
    local: "'Source Serif 4 Variable Italic'",
  ),
  (
    font-face: (
      font-family: "'Noto Naskh Arabic'",
    ),
    webfont: "/fonts/subsets/NotoNaskhArabic-Regular.woff2",
    local: "'Noto Naskh Arabic Regular'",
  ),
  (
    font-face: (
      font-family: "'Noto Serif Devanagari'",
    ),
    webfont: "/fonts/subsets/NotoSerifDevanagari-Regular.woff2",
    local: "'Noto Serif Devanagari Regular'",
  ),
  (
    font-face: (
      font-family: "'Noto Serif Georgian'",
    ),
    webfont: "/fonts/subsets/NotoSerifGeorgian-Regular.woff2",
    local: "'Noto Serif Georgian Regular'",
  ),
  (
    font-face: (
      font-family: "Charis",
      font-weight: "400",
    ),
    webfont: "/fonts/subsets/Charis-Regular.woff2",
    local: "Charis",
  ),
  (
    font-face: (
      font-family: "'Fira Code VF'",
      font-weight: "300 700",
      ascent-override: "115%",
      descent-override: "35%",
      size-adjust: "90%",
    ),
    webfont: "/fonts/subsets/FiraCode-VF.woff2",
    local: "'Fira Code'",
  ),
  (
    font-face: (
      font-family: "Twemoji",
    ),
    webfont: "/fonts/subsets/Twemoji.woff2",
    local: "Twemoji",
  ),
  (
    font-face: (
      font-family: "'Noto Sans Math'",
    ),
    webfont: "/fonts/subsets/NotoSansMath-Regular.woff2",
    local: "'Noto Sans Math Regular'",
  ),
  (
    font-face: (
      font-family: "'Noto Sans Symbols'",
    ),
    webfont: "/fonts/subsets/NotoSansSymbols-Regular.woff2",
    local: "'Noto Sans Symbols Regular'",
  ),
  (
    font-face: (
      font-family: "'Noto Sans Symbols'",
      font-weight: "500",
    ),
    webfont: "/fonts/subsets/NotoSansSymbols-Medium.woff2",
    local: "'Noto Sans Symbols Medium'",
  ),
  (
    font-face: (
      font-family: "'Noto Sans Symbols'",
      font-weight: "700",
    ),
    webfont: "/fonts/subsets/NotoSansSymbols-Bold.woff2",
    local: "'Noto Sans Symbols Bold'",
  ),
  (
    font-face: (
      font-family: "'Noto Sans Symbols 2'",
    ),
    webfont: "/fonts/subsets/NotoSansSymbols2-Regular.woff2",
    local: "'Noto Sans Symbols 2 Regular'",
  ),
)

#let (fonts-css, fonts-assets) = if "skip-fonts" in sys.inputs {
  ("", [])
} else {
  let assets = []
  let css = ""
  for font in fonts {
    let name = font.webfont.find(regex(`[^/]+$`.text))
    let (path, asset) = hoist-asset(name, read(font.webfont, encoding: none))
    assets += asset
    css += (
      "@font-face{"
        + font.font-face.pairs().map(((k, v)) => k + ":" + v + ";").join()
        + "src:"
        + (
          "url(" + path + ")format('woff2')",
          ..(
            if type(font.local) == str { (font.local,) } else { font.local }
          ).map(it => "local(" + it + ")"),
        ).join(",")
        + ";}"
    )
  }
  (css, assets)
}
