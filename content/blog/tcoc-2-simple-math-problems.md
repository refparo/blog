---
title: TCOC002 简单的数学题
date: 2017-03-25
tags:
  - 编程
  - the Collision of Code
toc: true
---

[上一期](/blog/the-collision-of-code-1/) 做的题是 OI 题。这类题目可能对 Scala、Haskell 这类函数式的编程语言有点不公平。所以这个系列同时也会做一些其他题目。这一期的题目是 [欧拉计划](https://projecteuler.net/) 的前两题。欧拉计划中的题目都是数学题，这类题目会比较适合用函数式的风格来写。这两题也是比较简单的，这里我会用多种方法进行求解。

<!-- more -->

## [欧拉计划 Problem 1 Multiples of 3 and 5](https://projecteuler.net/problem=1)

> 如果我们列出所有小于 10 的 3 与 5 的倍数，我们会得到 3，5，6 和 9。它们的和是 23。请找出所有小于 1000 的 3 与 5 的倍数的和。

这一题作为欧拉计划的第一题自然是很简单的，你甚至可以手算出这道题的答案：$\frac { 333 \times (3 + 999) } 2 + \frac { 199 \times (5 + 995) } 2 - \frac { 66 \times (15 + 990) } 2 = 233168$

但是用程序写可能会更好理解些。

### C++

在 C++ 和 Java 里我都用循环来写。

```cpp
#include <iostream>

using namespace std;

int main() {
    int sum;
    for(int i; i < 1000; i++)
        if(i % 3 == 0 || i % 5 == 0)
            sum += i;
    cout << sum << endl;
}
```

### Java

```java
public class Main {

    public static void main(String[] args) {
        int sum = 0;
        for(int i = 0; i < 1000; i++)
            if(i % 3 == 0 || i % 5 == 0)
                sum += i;
        System.out.println(sum);
    }

}
```

可以看出 C++ 和 Java 的主体代码基本是一样的。

<del>只不过 Java 外面包的东西更多了。</del>

### Scala

得益于 Scala 的高灵活性，我们可以用很多种方法来写这个程序。

#### 传统循环法

```scala
object Main extends App {
  var sum = 0
  for (i <- 1 until 1000)
    if (i % 3 == 0 || i % 5 == 0)
      sum += i
  println(sum)
}
```

如果用传统的循环，那么 Scala 与 C++ 和 Java 并没有什么区别。

#### for 表达式法

然而这只是个更高级一点的循环法而已。

```scala
object Main extends App {
  var sum = 0
  for (
    i <- 1 until 1000
      if i % 3 == 0 || i % 5 == 0
  ) sum += i
  println(sum)
}
```

这并不是使用 for 表达式的正确姿势。

#### 函数式法

这才是真正能发挥 Scala 威力的方法！

```scala
object Main extends App {
  println((1 until 1000)
            .filter(x => x % 3 == 0 || x % 5 == 0)
            .reduceLeft(_ + _))
}
```

其实这里的`reduceLeft(_ + _)`还可以用`sum`代替，但这里就不用了。

### Haskell

既然是 Haskell 那自然要用最纯正的函数式了。

```haskell
main :: IO ()
main = print $ sum $
  filter (\x -> x `rem` 3 == 0 || x `rem` 5 == 0) [1..999]
```

其实和 Scala 的最后一种写法是相同的。

## [欧拉计划 Problem 2 Even Fibonacci numbers](https://projecteuler.net/problem=2)

> 一个裴波那契数列中的每一项都由前两项相加得到。以 1，2 开始的裴波那契数列的前十项是 1，2，3，5，8，13，21，34，55，89。请找出以 1，2 开始的裴波那契数列中所有不超过四百万的偶数项之和。

### C++

C++ 我还是只能用一个循环来解。

```cpp
#include <iostream>

using namespace std;

int main() {
    int sum;
    int a = 1; int b = 2; int c;
    while(b <= 4000000) {
        c = a + b;
        a = b;
        b = c;
        if(a % 2 == 0) sum += a;
    }
    cout << sum << endl;
}
```

### Java

我觉得我是不是要考虑以后不要写 Java 版本了……

```java
public class Main {

    public static void main(String[] args) {
        int sum = 0;
        int a = 1; int b = 2; int c;
        while(b <= 4000000) {
            c = a + b;
            a = b;
            b = c;
            if(a % 2 == 0) sum += a;
        }
        System.out.println(sum);
    }

}
```

### Scala

Scala 仍然可以写出好几个版本。

#### 传统循环法

```scala
object Main extends App {
  var sum = 0
  var a = 1; var b = 2; var c = 0
  while (b <= 4000000) {
    c = a + b
    a = b; b = c
    if (a % 2 == 0) sum += a
  }
  println(sum)
}
```

#### 手动尾递归法

```scala
object Main extends App {
  def loop (a: Int, b: Int, sum: Int): Int =
    if (b <= 4000000)
      loop(b, a + b, if (b % 2 == 0) sum + b else sum)
    else sum
  println(loop(1, 2, 0))
}
```

用了递归明显短了好多呢，并且这个尾递归会被编译器自动优化成循环。

#### Stream 法

作者表示这绝对是最清晰的方法（然而性能比前面几个差很多）。

```scala
object Main extends App {
  def fib (a: Int, b: Int): Stream[Int] =
    a #:: fib (b, a + b)
  println(fib(1, 2)
            .takeWhile(_ <= 4000000)
            .filter(_ % 2 == 0)
            .reduceLeft(_ + _))
}
```

### Haskell

Haskell 的惰性列表使这一切变得如此简单。

```haskell
main :: IO ()
main =
  print $ sum $ filter even $ takeWhile (<= 4000000) $ fib 1 2
  where fib a b = a : fib b (a + b)
```

## 总结

从这两道题就可以看出函数式的写法在解决这种偏数学向的问题的时候是很占优势的。不过函数式的性能通常要比命令式低，在列表处理时使用惰性计算对此会有一定改善。

## 测试环境

- 操作系统：Windows 10 14393 x64
- C++ 编译环境：GCC 6.3.0
- Java 编译环境：JDK 1.8.0_121
- Scala 编译环境：Scala 2.11.1
- Haskell 编译环境：GHC 8.0.2

## 下期预告

这个坑的更新频率大概是一周一更。下一期的题目是 [洛谷](https://www.luogu.org/) 上的 [「分数线划定」](https://www.luogu.org/problem/show?pid=1068)。另外，从下期开始将会移除 Java 版本，因为我感觉做这种题目的时候 Java 和 C++ 并没有什么区别。感兴趣的读者可以写别的语言的版本然后在 Github 上的 [Issues 页面](https://github.com/parorezo/blog/issues) 提交你的答案~
