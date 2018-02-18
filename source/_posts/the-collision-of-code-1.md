---
title: "the Collision of Code: 代码碰撞——在博客水更多文章的尝试[雾]"
date: 2017-03-18
tags:
  - 开发
  - the Collision of Code
toc: true
---

上一篇文章已经是去年八月份的了。过了半年才想起要在这写文章真是不好意思~

那么就直入正题吧！这次是要开一个系列坑，主要就是通过用各种不同的语言、不同的方法来做同一道题，来体现不同思想之间的区别，同时提高我的编程技术。「代码碰撞」这名字就是这么来的。

第一篇先写点简单的吧，先写 [洛谷](https://www.luogu.org/) 上「新手村」的第一个任务。有三道题，分别是[「A+B Problem」](https://www.luogu.org/problem/show?pid=1001)、[「小玉买文具」](https://www.luogu.org/problem/show?pid=1421)和[「小鱼的游泳时间」](https://www.luogu.org/problem/show?pid=1425)。

选这么简单的题目是为了比较简单地导入这些语言，求勿喷~

<!-- more -->

## 洛谷 P1001 A+B Problem

这个太简单了就不用多说了吧？

### C++

讲真 C++ 这语言我并不怎么擅长。

```cpp
#include <iostream>

using namespace std;

int main() {
    int a; int b;
    cin >> a >> b;
    cout << a + b << endl;
}
```

### Java

讲真这语言没什么很严重的毛病，就是太繁复……

```java
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        System.out.println(input.nextInt() + input.nextInt());
    }

}
```

### Scala

这是我喜欢的语言之一，不过在这种问题上与 Java 区别不大。

```scala
import java.util.Scanner

object Main extends App {
  val input = new Scanner(System.in)
  println(input.nextInt + input.nextInt)
}
```

### Haskell

这是我目前的主要语言。在写这道题的时候它最坑爹的地方是没有直接读一个整数的方法……

```haskell
main :: IO ()
main = do
  str <- getLine
  let [a, b] = map read $ words str :: [Int]
   in print $ a + b
```

嗯…… Haskell 与其他语言对比起来画风果然清奇。[雾]

## 洛谷 P1421 小玉买文具

这道题目是最简单的小学除法题。

> 题目描述：班主任给小玉一个任务，到文具店里买尽量多的签字笔。已知一只签字笔的价格是 1元 9角，而班主任给小玉的钱是 $a$元 $b$角，小玉想知道，她最多能买多少只签字笔呢。
>
> 输入输出格式：
>
> 输入格式：输入的数据，在一行内，包括两个整数，依次表示 $a$ 和 $b$，$a \leq 10000$，$b \leq 9$。
>
> 输出格式：输出一个整数，表示小玉最多能买多少只签字笔。

### C++

```cpp
#include <iostream>

using namespace std;

int main() {
    const int value = 1 * 10 + 9;
    int a; int b;
    cin >> a >> b;
    cout << (a * 10 + b) / value << endl;
}
```

### Java

```java
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        final int VALUE = 1 * 10 + 9;
        Scanner input = new Scanner(System.in);
        System.out.println(
            (input.nextInt() * 10 + input.nextInt()) / VALUE
        );
    }

}
```

充分的体现出了 Java 的烦人……

### Scala

```scala
import java.util.Scanner

object Main extends App {
  val value = 1 * 10 + 9
  val input = new Scanner(System.in)
  println((input.nextInt() * 10 + input.nextInt()) / value)
}
```

### Haskell

```haskell
main :: IO ()
main = do
  str <- getLine
  let value = 1 * 10 + 9
      [a, b] = map read $ words str :: [Int]
   in print $ (a * 10 + b) `div` value
```

Haskell 中的除法类似于 Pascal。

## 洛谷 P1425 小鱼的游泳时间

这一题比前两题略微复杂一点。

> 题目描述：伦敦奥运会要到了，小鱼在拼命练习游泳准备参加游泳比赛。这一天，小鱼给自己的游泳时间做了精确的计时（本题中的计时都按 24 小时制计算），它发现自己从 $a$ 时 $b$ 分一直游泳到当天的 $c$ 时 $d$ 分，请你帮小鱼计算一下，它这天一共游了多少时间呢？
>
> 输入输出格式：
>
> 输入格式：一行内输入 4 个整数，分别表示 $a$，$b$，$c$，$d$。
>
> 输出格式：一行内输出 2 个整数 $e$ 和 $f$，用空格间隔，依次表示小鱼这天一共游了多少小时多少分钟。其中表示分钟的整数 f 应该小于60。

### C++

```cpp
#include <iostream>

using namespace std;

int main() {
    int a; int b; int c; int d;
    cin >> a >> b >> c >> d;
    int e = c * 60 + d - a * 60 - b;
    cout << e / 60 << ' ' << e % 60 << endl;
}
```

### Java

```java
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        int a = input.nextInt(); int b = input.nextInt();
        int e = input.nextInt() * 60 + input.nextInt() - a * 60 - b;
        System.out.println(e / 60 + " " + e % 60);
    }

}
```

### Scala

```scala
import java.util.Scanner

object Main extends App {
  val input = new Scanner(System.in)
  val a = input.nextInt(); val b = input.nextInt()
  val e = input.nextInt() * 60 + input.nextInt() - a * 60 - b
  println(e / 60 + " " + e % 60)
}
```

### Haskell

```haskell
main :: IO ()
main = do
  str <- getLine
  let [a, b, c, d] = map read $ words str :: [Int]
      e = c * 60 + d - a * 60 - b
   in putStrLn $ (show $ e `div` 60) ++ ' ' : (show $ e `rem` 60)
```

## 总结

第一期各个语言的差别就已经很明显了啊……

但是，这些题目都还不能表现出这些语言的根本差异。目前能看出的也就只有语法的区别和标准库的区别。

那就让我们继续期待下一期把~

PS. 我自己都感觉这一期好水……

## 测试环境

- 操作系统：Windows 10 14393 x64
- C++ 编译环境：GCC 6.3.0
- Java 编译环境：JDK 1.8.0_121
- Scala 编译环境：Scala 2.11.1
- Haskell 编译环境：GHC 8.0.2
