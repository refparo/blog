---
title: 泛人类中间语
date: 2020-07-28
toc: true
draft: true
---

泛人类中间语（简称“中间语”）是飞升[^ascension]前泛人类共和国官方创制并使用的工程辅助语，属于分析语，音系简单，具有逻辑语言的特点。

[^ascension]: 创造超人工智能。

## 音系

音节结构为 (C)V(Co)。

| 辅音 C | 唇 | 龈 | 软腭 |
|-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **鼻音** | m [m] | n [n] | [ ]() |
| **塞音** | p [pʰ~p]<br>b [b] | t [tʰ~t]<br>d [d] | k [kʰ~k]<br>g [g] |
| **擦音** | f [ɸ]<br>w [β̞~β] | s [s]<br>z [dz~z] | [ ]() |
| **闪音** | [ ]() | r [ɾ~l] | [ ]() |

清塞音可以不送气。

| 元音 V | 前 | 央 | 后 |
|-:|:-:|:-:|:-:|
| **闭** | i [i] | [ ]() | u [ɯ~ɯᵝ] |
| **中** | e [e̞] | [ ]() | o [ɤ̞~ɤ̞ᵝ] |
| **开** | [ ]() | a [ä] | [ ]() |

| 韵尾 Co | 解释 |
|-:|:-|
| 元音 /R/ | 即长元音和双元音的第二拍<br>长元音有：aa, ee, oo，双元音只有 ai |
| 阻音 /Q/ | 只出现于阻音前，把后面的辅音延长一拍<br>正字法用重复后面的辅音字母表示 |
| 鼻音 /N/ | 在鼻音和塞音前发对应的鼻音，在其它音前实现为鼻化元音<br>在 m, p, b 前写作 m，在元音前写作 n-，其他情况写作 n |

### 音韵规则

- ni > [ɲi]
- si > [ɕi]
- zi > [dʑi~ʑi]
- f > [h]（在非助词词首，且后面不是 u 时；写作 h）
- fi > [çi]（写作 hi）

### 节奏与重音

中间语是一门音拍语言，每一拍的时间大致等长。一般一音节为一拍，三种特殊音节尾单独占一拍。

中间语是一门高低重音语言，有高中低三调。谓词、类谓词和结句词以中或高调开始，上升到高调后可以维持到单词末，或者下降到低调，然后可以在低调和中调之间摆动，最终以低调结尾。助词为低调。叹词音调任意，但最好是和谓词相同。

## 语法

- 谓词
  - 数词
    - 0~4 nae tasi gee ria mun
    - 5~9 sau yun hire mai bii
    - ×10<sup>1~2</sup> dai hasu
    - ×1000<sup>1~3</sup> kemi mega gasa
    - 半 dau
    - 小数点 toku
    - 复数 ra
- 类谓词
  - S1 名词化（Sn）标记 ga
  - λ 标记 ran
- 助词
  - 论元助词
    - 名词位助词（冠词，按优先级排序）
      - 全称冠词 mV
      - 存在冠词 nV
      - 有定冠词 rV
      - 引用冠词 zV
    - 命题位助词 sV
  - 修饰语助词 kV
  - 位格助词 dV = ni ma kV
- 叹词

由于中间语的语法比较抽象，下面我们将通过分析例子来讲解语法。

```
TODO
- 写程序管理词典
- 重做体态
- 重做全部词汇，使之更加对称、一致
```

```
新版词法

词干
  -量词-(引用标记)-(类型标记)
  -(黏着副词*)-(变量标记)-(格标记|修饰语标记)-树标记

# 词干规定：不允许含有两个 za

量词：
  全称 -s-
  存在 -n-
  有定 -r-

（剩下的可用辅音：mpbtdkgfwz）

引用标记：
  单词名称 -ez-
  短语名称 -oz-
  内容 -az-

# Paro-r-ez-o 帕勒（人名）
# Airenaku-s-i Un-r-oz-o 六光分（小说题）
# “ha-r-ah-i ai-r”-az-ag-a he-r-u uma-r-o. 他说：“爱你。”

类型标记：
  指物 -om-
  指事 -em-

黏着副词：
  否定 -im-
  标记 -Vp-
  体态：
    ……
```

| \ | 变量标记 e | 格标记 a |
|-:|:-|:-|
| 无 w | -ew- | / |
| 主格 b | -eb- | -ab- |
| 宾格 f | -ef- | -af- |
| 间接格 t | -et- | -at- |
| 内容格 g | -eg- | -ag- |
| λ | -ek(Vp)(Vp)- | / |
| 位格 | / | -ad- |

```
修饰语标记 -ak(Vp)-

# 经典例句：
# 我满足地把头给他摸。
# 我-r-om-eb-at-a 满足-r-em-eb-ak-et-e 他-r-om-eb-ab-i 摸-r-em-ef-ak-ew-u 头-r-em-ew-o.
# mirata meemurakete herabi fuoraku nazoro.

树标记：
  第一个子节点 -a
  最后一个子节点 -u
  中间子节点 -e
  唯一子节点 -i
  根节点 -o

引用括号：
  za-X-za … X 整体作为词干
    X 是一串不包含 za 的合法的 Rokira 音节，
    且引用内容中未出现过和 X 读音或拼写相同的片段。
    引用内容可以是任意语言。

# zaraza “What the f*ck?” ranaga heru umaro.
# za-ra-za “What the f*ck?” ra-n-ag-a he-r-u uma-r-o.
# 引用开始 “What the f*ck?” 引用结束-∃-内容格-[ 他-ι-] 说-ι-。
# 他说：“What the f*ck?”

# 测试
#
# 1. 他坐起来，理了理穿航天服弄乱的蓬松尾巴。
#    旧：he-ra siti-si tada-se, rete-ka sononsa-ni sera-si ta-si niru-ki kidi-si ke-su re-ka sihi-ku sippo-ru sati-su sa-so.
#    新：he-ra siti-ri tada-re, sononsa-ni sera-ni ta-ni niru-naka kidi-nu ke-refaka sihi-naku sippo-ru sati-ru sa-ro.
```

| 动词分类 | -过程 | +过程 |
|-:|:-:|:-:|
| **+影响** | achievement | accomplishment |
| **-影响** | semelfactive | activity |
| **状态** | state ||

```
体态：
  未然体 : 事件 -> 状态 = 事件开始前
  经验体 : 事件 -> 状态 = 事件结束后
  惯常体 : 事件 -> 状态 = 事件经常发生

  反复体 : 事件 -> +过程 = 事件连续多次发生的过程

  开始体 : * -> -过程 = 事件/状态开始
  终结体 : * -> -过程 = 事件/状态结束

  进行体 : +过程 -> 状态 = 事件进行中

  完整体 : +过程 -> -过程 = 过程中任意一点
  单变体 : +过程 -> -过程 = 把过程看作一点

  完成体 : +影响 -> 状态 = 事件影响中
```

<style>
html body h1, html body h2, html body h3,
  html body h4, html body h5, html body h6 {
  break-after: avoid;
}
p {
  break-inside: avoid;
}
blockquote table tr td,
  blockquote table tr th {
  font-weight: normal;
  border: none;
  padding: 0 0.25em;
  white-space: nowrap;
  text-align: center;
}
blockquote table tr td:first-child,
  blockquote table tr th:first-child {
  padding-left: 0;
  text-align: right;
}
blockquote table tr td:last-child,
  blockquote table tr th:last-child {
  padding-right: 0;
}
blockquote table tr th {
  border-bottom: 1px black solid;
}
@media print, (width: 736px) and (height: 700px) {
  html body blockquote {
    color: #4E6A6A;
  }
  html body table {
    display: block;
    width: auto;
  }
  p a {
    position: relative;
  }
  p a:before {
    content: attr(href);
    font-size: x-small;
    position: absolute;
    bottom: 1.25rem;
    line-height: 1em;
    color: #6D8585;
  }
  li a:after {
    content: " (" attr(href) ")";
    font-size: small;
    color: #6D8585;
  }
}
</style>
