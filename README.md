# Paro 的个人网站

## 依赖

构建依赖：

- [Typst](https://typst.app/)
- `git submodules update --init`
- harfbuzz-utils
- woff2
- uv
- `./blog prepare-fonts`

开发依赖：

- npm
- `npm i`
- [typstyle](https://github.com/typstyle-rs/typstyle)

## 构建

`./blog build`

## 开发

- 启动开发服务器：`./blog`
- 格式化代码：`./blog format`
- 清理：`./blog clean`

本博客使用了 Typst 实验性的 bundle 和 html 特性，因此在使用 Tinymist 开发和写作时，需要添加额外的特性和输出格式参数。对于 Zed 编辑器，可以使用以下配置。

```jsonc
{
  "lsp": {
    "tinymist": {
      "settings": {
        "typstExtraArgs": ["--features=html,bundle", "--font-path=fonts"],
        "exportTarget": "bundle",
      },
    },
  },
}
```

## 历史

<!-- oxfmt-ignore -->
| 时间 | 事件 |
| --- | --- |
| 2026 年 11 月  0 日 | 使用 Typst 重写 |
| 2023 年  6 月 11 日 | 迁移到 Cloudflare Pages 托管 |
| 2022 年 10 月 30 日 | 合并两个栏目，简化页面路径结构 |
| 2021 年  6 月 17 日 | 启用独立域名 paro.one，托管于 Vercel |
| 2021 年  2 月  8 日 | 启用更加简洁的新样式 |
| 2020 年  5 月 31 日 | 迁移到 Hugo 生成器 |
| 2019 年  4 月  6 日 | 迁移到 Gatsby 框架 |
| 2018 年  2 月 14 日 | 启用自制主题 [Mono](https://github.com/refparo/hexo-theme-mono) |
| 2016 年  7 月 11 日 | 迁移到 Hexo 生成器，使用 [Icarus](https://github.com/ppoffice/hexo-theme-icarus) 主题，托管于 GitHub Pages |
| 2016 年  1 月 21 日 | 迁移到 Ghost |
| 2015 年  5 月 31 日 | 网站建立，使用 WordPress，托管于 OpenShift |
