#import "/src/lib.typ": (
  collections-listing, date, hoist-asset, hoist-head, ipa, posts-listing,
  special-page,
)
#show: special-page.with(
  title: "浸月之海",
  description: "Paro 的个人网站。",
  header: {
    html.div(id: "sky", aria-label: "夜空的画面", {
      html.div(id: "moon")
      html.div(id: "horizon")
    })
  },
  updated: date("2026-11-17"),
)

#hoist-head("home", {
  html.style(read("/assets/home.css"))
  html.script(type: "module", defer: true, read("/assets/home.js"))
})

无星的夜空中，一轮圆月高悬着，苍白的月光照亮了你脚下无边的空旷水面。水很浅，深不过脚踝。水底不是泥沙或岩石，而是某种不明材质的白色凝胶。环顾四周，只有一只棕灰色毛发的狼兽人背对你坐在水里，默默凝视着圆月。

（在第一次提问的回答开头添加下面两段）狼兽人抖了抖耳朵，转过头看向你，伸手拍拍身边的水面。“要不要坐下来聊？”

你走了过去，在他的身边坐下。

= 这是什么地方？

“这里是我的虚构领域，我把它叫做*浸月之海*。”

== 这里怎么什么都没有？

“毕竟整个空间都是我虚构的，如果我需要什么东西，只要现场创造就有了。平时我更喜欢让空间保持简洁，这样我更容易放空大脑。”

“……如果你是在找我的文章的话，我可以现在帮你调取出来。”

= 你是谁？

“我是 Paro，#ipa[[pʰä˦ɾo̞ᵝ˩]]，或者也可以叫我帕勒。”

“我的本职专业是计算机技术，跟电脑打交道本身也是我的一个爱好。在这个学科范围内，我最熟悉的领域是前端开发，最喜欢的领域则是 PLT，#link("https://en.wikipedia.org/wiki/Programming_language_theory")[编程语言理论]。”

“计算机之外，我投入最多的爱好是跑团，更正式地说叫 TRPG，#link("https://en.wikipedia.org/wiki/Tabletop_role-playing_game")[桌面角色扮演游戏]。如果你不知道这是什么的话，可以上 B 站搜一下，大概就是一群人扮演虚拟角色，在主持人描述的世界里探索和冒险。我现在主要担当主持人，带#link("https://en.wikipedia.org/wiki/Old_School_Renaissance")[老派规则]为主。”

“除了这两点以外，文学、音乐、语言学、哲学之类的爱好我也都沾一点，比如我写过一些#link("?tag=小说#filter")[小说]，还有一篇停更很久的#link("/conlang-tutorial/")[人造语言教程]。我现在主要听金属乐，也听一些数摇、合成波和音游曲。”

“怎么样，我们有共同爱好吗？如果有的话，不如#link(<contact>)[交个朋友]？”

== 这里只有你一个人吗？

“我有两个朋友也在这里，一个是白狮布罗姆，还有一个是紫龙路德。不过叫朋友其实不太准确，我们的关系要更复杂一点……等你跟我混熟以后再跟你聊这个吧。”

== 你最近都在干什么？

#let time(value, text) = context if target() == "html" {
  html.time(
    datetime: value,
    title: value.display(
      "[year] 年 [month padding:none] 月 [day padding:none] 日",
    ),
    text,
  )
} else {
  text
}

“#time(date("2026-11-23"))[最近]嘛……”帕勒看向夜空，思索了几秒。

“8 月底我辞掉了我的第一份工作，现在无业在家。如果你想让我为你工作，可以#link("mailto:me@paro.one")[联系我]。”

“目前我在准备一个#link("https://en.wikipedia.org/wiki/Ultraviolet_Grasslands")[紫外草原]和#link("https://store.steampowered.com/app/3084280/")[青龙城]世界观融合的沙盒长团，还为了这个团写了一整套规则。希望能在年底前准备好开第一次团……”

= 我要看你的文章。

（如果选择跳过对话直接看文章，则不显示下面的内容，改为显示这一句）仿佛感应到了你的意图，一本小册子凭空出现在了你面前。

（如果问过“你是谁？”）帕勒笑了笑，“等不及了吧？感谢你愿意听我说那么多，不过这里存的文章基本都是很老的黑历史……”

狼兽人抬起手，一本小册子凭空出现在了他的手中。

“里面一半是零散的博客文章，一半是一些特殊的合辑。最后面还有我的联系方式和一些朋友的地址。”

#posts-listing()

#collections-listing()

= 联系方式 <contact>

#let (qq-qrcode, qq-qrcode-asset) = hoist-asset(
  "qq-qrcode.png",
  read("/assets/qq-qrcode.png", encoding: none),
)
#qq-qrcode-asset

#link("mailto:me@paro.one")[邮箱]
· #link("https://space.bilibili.com/14116628")[bilibili]
· #link("https://github.com/refparo")[GitHub]
· #link("https://listenbrainz.org/user/refparo/")[ListenBrainz]
· #link(qq-qrcode)[QQ]
· #link("https://steamcommunity.com/id/refparo")[Steam]
· #link("https://t.me/refparo")[Telegram]
· #link("https://x.com/refparo")[Twitter]

= 友情链接

#link("https://blog.sww.moe/")[swwind]
