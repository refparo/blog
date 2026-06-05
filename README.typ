#set document(
  title: "README",
  author: "Paro",
)

#show: doc => context {
  if target() == "bundle" {
    document("README.html", doc)
  } else {
    doc
  }
}

= 帕勒的博客

== 构建

- 构建指令：`make`
- 启动开发服务器：`make watch`

== 依赖

本博客使用了 Typst 尚未正式发布的 bundle 特性，因此需要从 git 构建并安装 Typst：

```bash
$ cargo install --git https://github.com/typst/typst
```

开发和写作时，需要使用 nightly 分支的 Tinymist：

```bash
$ cargo install --git https://github.com/typst/tinymist --branch nightly
```

另外，还需要配置 Tinymist 使用与构建参数一致的特性和输出目标参数。对于 Zed 编辑器，可以使用以下配置。

```jsonc
// 注意这段配置必须写进全局设置。由于 Typst 插件的 bug，放在项目设置里不会生效。
// https://github.com/zed-industries/zed/issues/43932
{
  "lsp": {
    "tinymist": {
      "settings": {
        "typstExtraArgs": [
          "--features=html,bundle",
          "--font-path=fonts",
          "--package-path=packages",
        ],
        "exportTarget": "bundle",
      },
    },
  },
}
```

== 字体

- 标点：统一使用思源宋体
- 正文：思源宋体 / Source Serif
- 强调：朱雀仿宋 / Source Serif italic
- 加重强调：思源黑体 bold / Source Sans bold
- 代码：思源黑体 / Fira Code
- 数学：New Computer Modern
- IPA：Charis SIL
- 子集化：harfbuzz-utils
- 压缩：woff2
