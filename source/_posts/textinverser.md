---
title: TextInverser 文字反转器
date: 2016-01-28
tags:
  - 编程
thunbnail: /posts/textinverser/images/example.jpg
---
![效果图](/posts/textinverser/images/example.jpg)

这是我花了两个晚上用Scala做出来的一个简单的小工具，能把输入的文字反向输出，并且能实时转换。
<!-- more -->
由于用的是Scala，所以编译的Jar包里有很大一部分都是scala库←_←其实真正的我自己写的程序文件只有2KB多一点。

做这个小工具的原因是在群上看到一些人发反过来的文字。所以为了方(yu)便(le)，我就做了这个小工具出来。一方面方便发反向的文字，另一方面别人发的反向文字也能用这个正向输出来。

程序主类的代码有62行，里面大部分都是界面的代码，实际用来转换并显示的其实只有一行:`output.setText(new StringBuffer(input.getText()).reverse().toString())`

最后贴一张动态效果图:
![动态效果图](images/example.gif)

Jar和源码:
Jar: [点此](files/TextInverser.jar)
源码: [点此](files/TextInverser_src.zip)
***
P.S. 这个程序使用了[huanghongxun](https://github.com/huanghongxun)的HelloMinecraftLookAndFeel，GitHub链接: [点此](https://github.com/huanghongxun/HMCL/tree/release/MetroLookAndFeel)。
