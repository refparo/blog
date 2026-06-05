#import "/src/lib.typ": include-document, setup, with-source-path

#set text(lang: "zh", region: "cn")
#set raw(
  syntaxes: (
    // from https://github.com/buzden/sublime-syntax-idris2/blob/4d8eb35a38254d422030e77b4933530008dd3c6e/idris2.sublime-syntax
    "assets/sublime-syntax-idris2/idris2.sublime-syntax",
  ),
  // from https://github.com/SublimeText/LegacyColorSchemes/blob/6774cf43fb63b5304057a1295de2606bce1da7ce/Solarized%20(Dark).tmTheme
  theme: "assets/sublime-legacy-color-schemes/Solarized (Dark).tmTheme",
)

#set figure.caption(position: top)
#show figure.where(kind: "practice"): set figure(
  supplement: "练习",
  numbering: "1",
)
#show figure.where(kind: "example"): set figure(
  supplement: "例",
  numbering: "1",
)
#set footnote(numbering: "[1]")
#set outline(depth: 2)

#show: setup.with(
  title: "浸月之海",
  author: "Paro",
  favicon: read("/assets/favicon.ico", encoding: none),
  copyright: [#sym.copyright #datetime.today().year() Paro],
  links: (
    link("https://github.com/refparo/blog/discussions")[参与讨论],
    link("/#contact")[联系作者],
    with-source-path(source => link(
      "https://github.com/refparo/blog/blob/"
        + if "commit" in sys.inputs { sys.inputs.commit } else { "master" }
        + source,
    )[源代码]),
    // link("/atom.xml")[RSS],
  ),
)

#asset("/_headers", read("/assets/_headers"))

// @typstyle off
#[

#include-document("/content/index.typ")
#include-document("/content/404.typ", path: "/404.html")

#include-document("/content/posts/20230102-twenty-twenty-two.typ")
#include-document("/content/posts/20221005-donglingshan/index.typ")
#include-document("/content/posts/20220728-introducing-google-fonts-plus.typ")
#include-document("/content/posts/20220507-sunken-in-wind.typ")
#include-document("/content/posts/20220405-gravestone.typ")
#include-document("/content/posts/20220316-singularity.typ")
#include-document("/content/posts/20211225-twenty-twenty-one.typ")
#include-document("/content/posts/20211101-suiciding-ghost.typ")
#include-document("/content/posts/20211030-a-letter-to-a-stranger.typ")
#include-document("/content/posts/20210716-full-notes-of-installing-arch-in-2021.typ")
#include-document("/content/posts/20210410-beast-and-human.typ")
#include-document("/content/posts/20210407-edge-case.typ")
#include-document("/content/posts/20200815-twelve-light-minutes.typ")
#include-document("/content/posts/20200723-frost-flower.typ")
#include-document("/content/posts/20200620-library-at-the-end-of-space-and-time.typ")
#include-document("/content/posts/20190908-higher-kinded-types-in-typescript.typ")
#include-document("/content/posts/20180725-run-vscode-on-archlinux-on-wsl/index.typ")
#include-document("/content/posts/20180405-type-safe-printf-in-idris.typ")
#include-document("/content/posts/20180215-use-lxrunoffline-to-install-arch-linux/index.typ")

#include-document(
  "/content/collections/conlang-tutorial/index.typ",
  aliases: "/research/conlang-tutorial/",
)
#include-document(
  "/content/collections/conlang-tutorial/0-introduction.typ",
  aliases: "/conlang-tutorial/introduction/",
)
#include-document("/content/collections/conlang-tutorial/1-phonology/index.typ")
#include-document("/content/collections/conlang-tutorial/1-phonology/1-pronounciation/index.typ")

#include-document("/content/collections/eighteen/index.typ")
#include-document("/content/collections/eighteen/20201101-mountain-climbing.typ")
#include-document("/content/collections/eighteen/20201112-after-supper.typ")
#include-document("/content/collections/eighteen/20210216-snowy-night.typ")
#include-document("/content/collections/eighteen/20210320-missing-dream.typ")
#include-document("/content/collections/eighteen/20210525-fantasyland.typ")
#include-document("/content/collections/eighteen/20210610-gaokao-journal.typ")
#include-document("/content/collections/eighteen/20210613-short-poems.typ")
#include-document("/content/collections/eighteen/20210616-afterword.typ")

#include-document("/content/collections/gifts/index.typ")
#include-document("/content/collections/gifts/20220414-husky-in-the-lab.typ")

#include-document("/content/collections/rubble/index.typ")
#include-document("/content/collections/rubble/20211110-river-sand.typ")
#include-document("/content/collections/rubble/20220520-water-flow.typ")

#include-document("/content/collections/trpg-character-backstories/index.typ")
#include-document("/content/collections/trpg-character-backstories/20211010-extinguished.typ")
#include-document("/content/collections/trpg-character-backstories/20220120-oracle.typ")
#include-document("/content/collections/trpg-character-backstories/20221027-escaping-eagle.typ")
#include-document("/content/collections/trpg-character-backstories/20221124-buzzing-of-horror.typ")
#include-document("/content/collections/trpg-character-backstories/20230302-light-deprived-child.typ")
#include-document(
  "/content/collections/trpg-character-backstories/20230720-1-kuto-and-amandla.typ",
  aliases: "/trpg-character-backstories/20230720-kuto-and-amandla/",
)
#include-document(
  "/content/collections/trpg-character-backstories/20230720-2-agony-onyx.typ",
  aliases: "/trpg-character-backstories/20230720-agony-onyx/",
)

]
