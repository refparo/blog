#import "@project/templates:0.0.0": (
  date, home, hyperfic-page, ipa, post-listing, use-hyperfic,
)
#show: home(updated: date("2026-06-06"))
#show: use-hyperfic()

#hyperfic-page(
  [
    你来到了一片看不到边际的水面上。水很浅，深不过脚踝。水底不是泥沙或岩石，而是某种凝胶触感的不明物质。水面上方是无星的夜空，一轮圆月散发着苍白的月光。
  ],
  (<look-around>, [张望四周]),
  (<find-person>, [“有人吗？”]),
  (<skip-all>, [“我是来看博客文章的！”]),
) <landing>

#hyperfic-page(
  ending: true,
  [
    突然间，水底的凝胶移动起来，很快便升起了一面白色的书架。书架大部分是空的，只有中间一排摆着一些薄薄的小册子。

    这些就是所有的博客文章了。不过，你或许错过了什么？
  ],
  (".#landing", [（返回开始）]),
) <skip-all>

#hyperfic-page(
  [
    四处空无一物，陪伴你的只有月亮，以及月亮和你的倒影。你的呼吸与心跳在耳中清晰可闻。
  ],
  (<walk-around>, [四处走走]),
  (<sit-down>, [坐下]),
  (<find-person>, [“有人吗？”]),
) <look-around>

#hyperfic-page(
  [
    你在空旷的水面上漫无目的地行走。脚踏在水面上发出哗哗的水声，接着便被那种凝胶似的物质所承托，如同脚底按摩一般。

    圆月恒定不动地悬挂在空中。水面上没有任何参照物，只有你的脚步产生的水波能让你从视觉上感知到自己在移动。或许此刻即使闭上眼睛，于你也没什么区别。
  ],
  (<sit-down>, [坐下]),
  (<close-eyes>, [闭眼]),
  (<find-person>, [“有人吗？”]),
) <walk-around>

#hyperfic-page(
  [
    你闭上了眼睛，仅凭自己的平衡感在这片无尽的水面上漫步。你细细感受着水的清凉、水底的柔软。一阵微风忽然拂过，在你的脚边兴起阵阵水波……

    突然，你一头撞到了什么高大的物体！突如其来的冲击让你一下失去了平衡，但你又感受到一只手臂从你的背后托住了你。你赶紧睁开眼。在你的面前，一个高大、健壮的白色狮兽人正对你憋着笑。

    “不好意思，没想到你真的会直接撞上来。我打扰到你了吗？”
  ],
  (<startled-walking>, [“你吓到我了！”]),
  (<no-problem>, [“没有没有。”]),
) <close-eyes>

#hyperfic-page(
  [
    终于厌倦了这种漫无目的的行走，你在水中坐下。水底的凝胶状物质在你的体重下微微下陷，轻柔地包裹起你的臀部。不得不说，这东西的手感真不错……
  ],
  (<lie-down>, [躺下]),
  (<rub-slime>, [揉捏]),
) <sit-down>

#hyperfic-page(
  [
    你躺了下来。清凉的水浸没了你的小半个身子，让你的四肢微微上浮，使你的肌肉更加放松。你不禁闭上了眼睛，享受着这种独特的体验，感受自己的身体逐渐被水和凝胶包裹……

    等等！这时你才突然意识到，自己正在水中下沉！一不留神间，你的半个身体已经被凝胶吞没。水底到底是什么东西？再不行动，你就要被彻底吞噬了！
  ],
  (<call-help>, [“救命！”]),
  (<give-up>, [放弃抵抗]),
) <lie-down>

#hyperfic-page(
  [

  ],
) <rub-slime>

#hyperfic-page(
  [
    你惊慌地大声呼救，一边试图逃离！神奇的是，似乎响应着你的呼救，水底的凝胶也停止了下沉，转而将你托举起来。正在你慌忙寻找平衡，想要在水中站起来时，一只长着肉垫和爪子的白色大手伸到了你的面前。
  ],
  (<grab-hand>, [抓住那只手]),
  (<avoid-hand>, [避开那只手]),
) <call-help>

#hyperfic-page(
  [

  ],
) <give-up>

// 布罗姆对话
#[
  #hyperfic-page(
    [
      就在你快要怀疑自己为何来到这个无人区时……

      “找谁呢？”一个温暖、沉稳的男声忽然在你背后响起。

      你转过身，发现一个高大、健壮的白色狮兽人正微笑着面对你。
    ],
    (<find-paro>, [“我是来找帕勒的。”]),
    (<who-are-you>, [“你是谁？”]),
    (<what-place>, [“这是什么地方？”]),
    (<what-slime>, [“水底是什么东西？”]),
  ) <find-person>

  #hyperfic-page(
    [
      那只大手一把抓住你的手，把你从水中拉了起来。你大口喘着气，还没从刚才的惊吓中恢复过来。与此同时，水底的凝胶则迅速恢复了它原本的样貌。

      “不好意思！这里很少有客人，这凝胶吓到你了吧？”

      一个温暖、沉稳的男声在你头顶响起。你抬起头，看到一个高大、健壮的白色狮兽人正以担心的表情看着你。
    ],
    (<startled-lying>, [“你把我吓得半死！”]),
    (<who-are-you>, [“你是谁？”]),
    (<what-place>, [“这是什么地方？”]),
    (<what-slime>, [“这到底是什么东西？”]),
    (<what-slime>, [“刚才是什么情况？”]),
  ) <grab-hand>

  #hyperfic-page(
    [
      “真的对不起！可能是凝胶发现你这么放松，把你当成帕勒了。”白狮双手合十向你道歉。
    ],
    (<who-are-you>, [“你是谁？”]),
    (<what-place>, [“这是什么地方？”]),
    (<what-slime>, [“这到底是什么东西？”]),
    (<what-slime>, [“刚才是什么情况？”]),
    (<find-paro>, [“我就是来找帕勒的。”]),
    (<whos-paro>, [“帕勒是谁？”]),
  ) <startled-lying>

  #hyperfic-page(
    [
      你避开了那只手，自己从水里站了起来。水底的凝胶迅速地恢复了它原本的样貌，仿佛刚才的意外从未发生过。

      “不好意思！这里很少有客人，这凝胶吓到你了吧？”

      一个温暖、沉稳的男声在你头顶响起。你抬起头，看到一个高大、健壮的白色狮兽人带着抱歉的笑容看着你。
    ],
    (<who-are-you>, [“你是谁？”]),
    (<what-place>, [“这是什么地方？”]),
    (<what-slime>, [“这到底是什么东西？”]),
    (<what-slime>, [“刚才是什么情况？”]),
  ) <avoid-hand>

  #hyperfic-page(
    [
      “那真是对不起！”白狮收回他的手臂，尴尬地耷拉下耳朵。

      “我能怎么补偿你吗？你来到这里，应该不只是为了散步？”
    ],
    (<money-compensation>, [“赔钱！”]),
    (<sexual-compensation>, [“肉偿！”]),
    (<read-articles>, [“我想看博客文章。”]),
    (<find-paro>, [“我是来找帕勒的。”]),
    (<who-are-you>, [“你是谁？”]),
    (<what-place>, [“我想知道这是什么地方。”]),
    (<what-slime>, [“水底是什么东西？”]),
  ) <startled-walking>

  #hyperfic-page(
    [
      “那就好！要是我吓跑了一个客人的话帕勒肯定会怪我的。”白狮收回他的手臂，抱歉地笑了笑。

      “不过，你从茫茫互联网来到这里，只是为了散步吗？”
    ],
    (<read-articles>, [“我想看博客文章。”]),
    (<find-paro>, [“我就是来找帕勒的。”]),
    (<whos-paro>, [“帕勒是谁？”]),
    (<who-are-you>, [“你是谁？”]),
    (<what-place>, [“我其实不知道这是什么地方。”]),
    (<what-slime>, [“水底是什么东西？”]),
  ) <no-problem>

  #hyperfic-page(
    [

    ],
  ) <who-are-you>

  #hyperfic-page(
    [

    ],
  ) <what-place>

  #hyperfic-page(
    [

    ],
  ) <what-slime>

  #hyperfic-page(
    [

    ],
  ) <whos-paro>

  #hyperfic-page(
    [

    ],
  ) <find-paro>

  #hyperfic-page(
    [

    ],
  ) <money-compensation>

  #hyperfic-page(
    [

    ],
  ) <sexual-compensation>

  #hyperfic-page(
    ending: true,
    [
      “如果只是想读文章的话，其实不必这么麻烦……”

      白狮一挥手，脚下的凝胶便开始移动起来。很快，从水底升起了一面白色的书架。书架大部分是空的，只有中间一排摆着一些薄薄的小册子。

      “这些就是帕勒的全部文章了。如果有什么别的问题，也可以问我。”
    ],
    (<find-paro>, [“我想找帕勒。”]),
    (<whos-paro>, [“帕勒是谁？”]),
    (<who-are-you>, [“你是谁？”]),
    (<what-place>, [“我其实不知道这是什么地方。”]),
    (<what-slime>, [“水底是什么东西？”]),
  ) <read-articles>
]

// 水下居室
#[

]

#hyperfic-page(
  [

  ],
)

#hyperfic-page(
  [],
  (".#landing", [（返回开始）]),
)

我大概是那种典型的样样通、样样不精的人。我的专业是 CS，本身也是我的一个爱好。其中我最感兴趣的领域是 PLT，#link("https://en.wikipedia.org/wiki/Programming_language_theory")[编程语言理论]。但我最近的注意力并不在这上面。这段时间我投入最多的爱好是跑团，或者叫 TRPG，#link("https://en.wikipedia.org/wiki/Tabletop_role-playing_game")[桌面角色扮演游戏]，也就是一群人扮演虚拟角色，在主持人描述的世界里探索和冒险的游戏。

除此之外，我感兴趣的还有文学、音乐、语言学、哲学，等等。所以你可以在文章列表里看到各种各样不同主题的内容，比如#link("/tag/小说/")[小说]、#link("/conlang-tutorial/")[人造语言教程]，当然还有一些#link("/tag/技术/")[技术类文章]。如果你也对这些中的某个感兴趣，我们都可以交个朋友。

大概就是这样。你可以在这些地方找到我：

- E-mail：#link("mailto:ref.paro@outlook.com")[ref.paro\@outlook.com]
- GitHub：#link("https://github.com/refparo")[\@refparo]
- QQ：#link("https://qm.qq.com/cgi-bin/qm/qr?k=hFVmcaXe8aYvA1rkKg_D0JQode5z-D_C&noverify=0")[Paro]
- Steam：#link("https://steamcommunity.com/id/refparo")[Paro]
- Telegram: #link("https://t.me/refparo")[Paro]
- Twitter：#link("https://twitter.com/refparo")[\@refparo]
- 微博：#link("https://weibo.com/refparo")[\@ref_Paro]
- 知乎：#link("https://zhihu.com/people/paro_ci")[\@Paro]

= 站史

_你问起这个地方的历史，于是面前的灰狼向你一一道来。_

#{
  show regex("\b\d\b"): it => context {
    if target() == "html" {
      html.span(style: "margin-left: 1ch", it)
    } else {
      h(measure(sym.space.fig).width)
      it
    }
  }
  show <history-table>: it => context if target() == "html" {
    html.style(
      ```
      #history-table :is(th, td):first-child {
        text-wrap: nowrap;
      }
      ```.text,
    )
    html.div(id: "history-table", it)
  } else { it }
  [#table(
    columns: (auto, 1fr),
    table.header([时间], [事件]),
    [2026 年  6 月  0 日], [网站使用 Typst 重写],
    [2022 年 10 月 30 日], [网站结构重构],
    [2022 年  7 月 27 日],
    [大规模调整网站排版，采用#link("https://github.com/sivan/heti")[赫蹏]的排版工具],

    [2021 年  6 月 17 日], [启用新域名：`paro.one`],
    [2021 年  2 月  8 日], [网站模板和样式重构],
    [2020 年  5 月 31 日], [博客改用 Hugo 生成器，结构和样式改动以适应新的需求],

    [2019 年  7 月 20 日], [博客样式调整],
    [2019 年  4 月  6 日], [博客改用 Gatsby 框架],
    [2018 年  2 月 14 日],
    [更换全新的自制主题 #link("https://github.com/refparo/hexo-theme-mono")[Mono]],

    [2016 年 12 月 11 日], [博客移回根目录],
    [2016 年 10 月 15 日], [博客移动到 `/blog/`，站点根目录另作他用],
    [2016 年  7 月 11 日],
    [博客改用 Hexo 生成静态页面，使用 Icarus 主题，发布于 GitHub Pages],

    [2016 年  1 月 21 日], [建立新的 Ghost 博客站],
    [2016 年初], [删除原 WordPress 站],
    [2015 年  5 月 31 日], [发布第一篇文章《Hello WordPress！》],
    [2015 年  5 月], [网站建立],
  ) <history-table>]
}

#post-listing()

= 友情链接

- #link("https://swwind.me/")[swwind]
