---
title: 我的自制博客主题完成了！
tags:
  - 开发
  - 博客
date: 2018-02-18
---

经过近半个月的~~低效的~~开发，我的自制博客主题终于完成了！

<!-- more -->

## 预览主题

你已经在预览了。

## ~~Bug~~ 特性

<script>
  function black() {
    document.body.parentElement.style = ""
  }
  function blue() {
    document.body.parentElement.style = `
      --theme-color-h: 200;
      --theme-color-s: 40%;`
  }
  function green() {
    document.body.parentElement.style = `
      --theme-color-h: 80;
      --theme-color-s: 40%;`
  }
  function dark() {
    document.body.parentElement.style = `
      --theme-color-h: 180;
      --theme-color-s: 40%;
      --color-0: hsl(var(--theme-color-h), var(--theme-color-s), 90%);
      --color-1: hsl(var(--theme-color-h), var(--theme-color-s), 80%);
      --color-2: hsl(var(--theme-color-h), var(--theme-color-s), 70%);
      --color-3: hsl(var(--theme-color-h), var(--theme-color-s), 25%);
      --color-4: hsl(var(--theme-color-h), var(--theme-color-s), 15%);`
  }
</script>

- 简洁的页面风格！~~抄袭 [hexo-theme-icalm](https://github.com/nameoverflow/hexo-theme-icalm) 的~~
- 先进的技术！~~不支持 IE~~
- 支持一切评论插件！[比如我的](#comment)
- 强大的自定义能力！可以自定义版权信息（看 [最底下](#footer-info)），还可以简单地自定义整个配色。预览（如果你在用电脑浏览，你也可以按 F12 查看代码。并且这些东西都是可以在一个配置文件里设置的）：
  <div>
  <input type="radio" name="theme" id="theme-black" onclick="black()" checked>
  <label for="theme-black">黑色主题</label>
  <input type="radio" name="theme" id="theme-blue" onclick="blue()">
  <label for="theme-blue">蓝色主题</label>
  <input type="radio" name="theme" id="theme-green" onclick="green()">
  <label for="theme-green">绿色主题</label>
  <input type="radio" name="theme" id="theme-neg" onclick="dark()">
  <label for="theme-neg">暗色主题</label>
  </div>
- 支持 $\KaTeX$！预览：
  $$f(x) = \int\_{-\infty}^\infty
    \hat f(\xi)\,e^{2 \pi i \xi x}
    \,d\xi$$
  $$\displaystyle \frac{1}{\Bigl(\sqrt{\phi \sqrt{5}}-\phi\Bigr) e^{\frac25 \pi}} = 1+\frac{e^{-2\pi}} {1+\frac{e^{-4\pi}} {1+\frac{e^{-6\pi}} {1+\frac{e^{-8\pi}} {1+\cdots} } } }$$
  $$\displaystyle \left( \sum_{k=1}^n a_k b\_k \right)^2 \leq \left( \sum_{k=1}^n a\_k^2 \right) \left( \sum_{k=1}^n b\_k^2 \right)$$
  $$\displaystyle 1 +  \frac{q^2}{(1-q)}+\frac{q^6}{(1-q)(1-q^2)}+\cdots = \prod_{j=0}^{\infty}\frac{1}{(1-q^{5j+2})(1-q^{5j+3})}, \quad\quad \text{for }\lvert q\rvert<1.$$
  注：由于是浏览器端渲染，因此源文件内的公式可能需要针对 Markdown 语法做一些转义。如上面第一个公式的源代码（注意 `\int` 后面那个 `\`）：
  ```latex
  f(x) = \int\_{-\infty}^\infty
    \hat f(\xi)\,e^{2 \pi i \xi x}
    \,d\xi
  ```

## 浏览器支持

Emmmmmm……其实我写这个主题的时候是特意多用新特性的，因此浏览器都需要比较新。考虑到这个主题的受众，这是可以接受的。

- 支持的浏览器：Edge 16+、Firefox ESR+、Chrome 49+、Safari 10+、Opera 36+。
- 完全不支持 IE。

拒绝旧浏览器，从我做起！

## 如何用它作为我的主题？

### 安装

这个浏览器需要 `hexo-renderer-jade` 插件：

```shell
$ npm i --save hexo-renderer-jade
```

然后在你的博客内把主题作为 submodule 添加：

```shell
$ git submodule add https://github.com/problem233/hexo-theme-mono.git themes/mono
```

更新时只需要这样：

```shell
$ git submodule update --remote
```

### 自定义

本博客有两部分自定义功能。

- 自定义配置：把主题目录下的 `_config.yml` 复制到 `<站点根目录>/source/data/mono.yml`，然后编辑它。
  - `menu`：设置左边（移动端在上面）的导航栏。
  - `avatar`：设置头像。
  - `social_links`：设置左下角（移动端在头像旁边）的外链。格式：
    ```yaml
    github: https://github.com/your_github/
    weibo: https://weibo.com/your_weibo
    steam: https://steamcommunity.com/profiles/your_steam/
    ```
    这里的图标用的是 [Font Awesome 4.7.0](https://fontawesome.com/v4.7.0/icons/)，所以只能用那里有的图标。
  - `icon`：设置网页图标。
  - `katex`：设置 $\KaTeX$ 的版本。设置这个选项是为了便于升级。
  - `comment`：设置下方的评论区。请填入 HTML 代码，代码内的 `MONOPAGEID` 会被主题自动替换成页面 ID。
  - `copyright`：设置底部的版权信息（仅限第一行）。也是 HTML 代码。
- 样式配置：（先新建后）编辑文件 `<站点根目录>/source/css/custom.css`，如果要覆盖主题的默认设置的话别忘了加上 `!important`。

### 如何添加标签页面？

（先新建后）编辑文件 `<站点根目录>/source/tags/index.html`，填入以下内容：

```markdown
---
title: 标签
layout: tags
---
```

## ~~我猜~~常见问题

### 没有 XXX 功能吗？

可能是因为我认为不需要（如：搜索），那么如果你真的需要就请 [fork](https://github.com/problem233/hexo-theme-mono) 后自行解决；也有可能是我没想到，那么请 [提交 issue](https://github.com/problem233/hexo-theme-mono/issues)。

### 有待添加……