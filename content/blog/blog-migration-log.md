---
title: 博客转移笔记
date: 2019-04-07
tags:
  - 编程
  - 博客
---

你如果关注这个博客，可能已经发现我很长时间没有发新的文章了。这是大部分因为，自寒假以来，我就一直在寻找更好的静态博客框架。Hexo 已经不再活跃更新，而且其功能也不能满足我的需求。那么为什么拖了这么长时间才完成迁移呢？在这段时间内，我尝试了很多种框架，包括自己写生成器。下面就是我的迁移路线——

<!-- more -->

# 自制生成器

我首先是试图自制生成器。自制生成器的确能对网站取得最大的掌控力，但是难度也相当大。我在自制生成器前就已经看到了 [Metalsmith](https://github.com/segmentio/metalsmith) 这个项目（之所以没有用它是因为它对 Typescript 不友好），因此有意地模仿了它的架构。而不同之处是我采用了 Promise 而非回调，以及我尽可能地采用了声明式（或者说函数式）的范式。我大概在寒假内花了一周时间完成了这个生成器，此时它的功能基本上已经完整了。然而，这时我发现这个架构完全不能加入 watch 功能……在做了一些尝试之后，我就放弃了这个自制的生成器。目前其代码已经丢失。

为了实现 watch 功能，我又看了像 [Gulp](https://gulpjs.com/) 这样的流式构建系统。我起先考虑了直接用 Gulp 生成网站，但 Gulp 也对 Typescript 不友好。于是我又参考 Gulp，依托 [RxJS](https://rxjs.dev/) 重写了之前的生成器，并尝试实现了 watch……实现的结果起初的确令我鼓舞，但接着我就遇到了页面之间互相依赖的问题。我没耐心自己解决这个问题，于是放弃了自己制作生成器的想法。

寒假的其余时间基本都被我用来娱乐、做作业，下面的过程都发生在寒假以后了。

# Gatsby

[Gatsby](https://www.gatsbyjs.org/) 也是我在之前就已经发现了的。当时我总是觉得 Gatsby 过于复杂——生成静态网站明明是挺简单的需求，为什么要用这么复杂的一个框架呢？由于我排斥复杂框架，当时我也只是对它浅尝辄止，没有深入研究。

# react-static

然后我就看到了 [react-static](https://github.com/nozzle/react-static)。从表面上来看，react-static 要比 Gatsby 简单得多，不涉及 GraphQL 之类的复杂内容。然而，实际上手之后我发现它其实比 Gatsby 更难用——由于用户少，社区小。

在看到 react-static 的同时我也发现了 [StaticGen](https://www.staticgen.com/) 这个静态生成器排行网站。虽然里面列举了很多静态生成器，但我感觉它们都大同小异，没有上手尝试。

# 再次尝试自制

在尝试了两个基于 [React](https://reactjs.org/) 的静态网站框架之后，我也试图自己写一个。然而在看到 [create-react-app](https://github.com/facebook/create-react-app) 背后那些复杂的细节之后，我就直接放弃了这个想法——我不想在工具链的问题上浪费更多时间了。

# 再次，Gatsby

于是我还是回到了 Gatsby。在理解了 [它的 Node 模型](https://www.gatsbyjs.org/docs/node-interface/) 之后，它的整个架构还是比较容易理解的。它的程序化生成页面的 API 虽然略显复杂，但给了用户足够的自由度。很多需求都有插件提供支持，但还是有一些常见于博客的需求没有被考虑到（或者没有文档）。其中我也在 Gatsby 的 Github 仓库提了 [一个问题](https://github.com/gatsbyjs/gatsby/issues/13148)，使用了一点不太优雅的 [Hack](https://github.com/problem233/blog/commit/d4d2f9dc3c629c0465adbed1ea3e6e29e128a01a)（或许这个不能算 Hack，但我有点代码洁癖）。不管怎样，我的博客最终还是用 Gatsby 搭建起来了。你现在看到的这个页面就是 Gatsby 渲染的。

# 总结

回顾整个迁移过程，为什么我只尝试了 Node.js 上的生成器呢？这主要是生态所导致的。我所需要的重要库，有的是 NPM 上的更好（如 [Remark](https://remark.js.org/)），还有的是只有 Node.js 上有（如 [KaTeX](https://katex.org/)）。可以说，Node.js 的流行与其生态是密不可分的。生态也导致我们无法脱离一些让人厌恶的东西，比如 [Webpack](https://webpack.js.org/)——生态的发展导致了前端开发复杂化。也正因如此，Node.js 的原作者才另立门户，创建 [Deno](https://deno.land/)。

最后，我的博客生成器算是暂时确定了。[旧的](https://github.com/problem233/blog/tree/old)和[新的](https://github.com/problem233/blog/tree/d4d2f9dc3c629c0465adbed1ea3e6e29e128a01a)博客源码都公开在 Github 以供参考。或许接下来我还会尝试自制博客生成器，但那就未完待续了……
