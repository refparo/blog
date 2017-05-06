---
title: TCOC006 两个因缺斯汀的数学题
date: 2017-05-06
tags:
  - 编程
  - the Collision of Code
toc: true
---

今天的题目是两道比较有趣的数学题： [欧拉计划](https://projecteuler.net/) 的 [Problem 9 Special Pythagorean triplet](https://projecteuler.net/problem=9) 和 [Problem 15 Lattice paths](https://projecteuler.net/problem=15)。另外，从本期开始我将会用 Rust 取代 Scala 来做题。

为了偷懒，这里的 C++ 版本就直接用 [某 Frank 同学](https://frankfoot.github.io/) 的了。

<!-- more -->

## 欧拉计划 Problem 9 Special Pythagorean triplet

这道题，真的，很简单。

勾股数是三个自然数 $a < b < c$ 组成的集合，并满足 $a ^ 2 + b ^ 2 = c ^ 2$。例如：$32 + 42 = 9 + 16 = 25 = 52$。

有且只有一组勾股数满足 $a + b + c = 1000$，求这组勾股数的乘积 $abc$。

### C++

注：[这是某 Frank 同学的解](https://frankfoot.github.io/Project-Euler/docs/9.html)。

<s>我有特别的格式化技巧~</s>

```cpp
    #include <iostream>

    using namespace std
;
    int main()
{     for (int a = 1; a <= 500; a++)
        for (int b = 1; b <= 500; b++)
{         int c = 1000 - a - b
;         if(a * a + b * b == c * c)
{           cout << a * b * c
;           return 0
;}}   return 1
;}
```

### Rust

对于这种简单题，Rust 和 C++ 并没有什么区别。

```rust
fn main() {
  for a in 1..500 {
    for b in a..500 {
      let c = 1000 - a - b;
      if a * a + b * b == c * c {
        println!("{}", a * b * c);
        return;
      }
    }
  }
}
```

### Haskell

```haskell
main = let (a, b, c) = head $
                       filter (\(a, b, c) -> a * a + b * b == c * c)
                         [(a, b, 1000 - a - b) |
                           a <- [1..500], b <- [a..500]]
         in print $ a * b * c
```

非常简单明了的列表操作，写成一行也不会非常降低可读性。

## 欧拉计划 Problem 15 Lattice paths

从一个 `2×2` 方阵的左上角出发，只允许向右或向下移动，则恰好有 6 条通往右下角的路径。

![Latttice paths](https://projecteuler.net/project/images/p015.gif)

对于 `20×20` 方阵来说，这样的路径有多少条？

### C++

这里仍然使用 [某 Frank 同学的解](https://frankfoot.github.io/Project-Euler/docs/15.html)。

```cpp
#include <iostream>
#include <cstring>

using namespace std;

int main() {
  long long f[22][22];
  memset(f,0,sizeof f);
  for (int i = 0; i <= 20; i++)
    f[0][i] = f[i][0] = 1;
  for (int i = 1; i <= 20; i++)
    for (int j = 1; j <= 20; j++)
      f[i][j] = f[i - 1][j] + f[i][j - 1];
  cout << f[20][20];
  return 0;
}
```

### Rust

在 Rust 里我实在想不出什么好方法，只好抄袭 Frank 的方法……

```rust
fn main() {
  let mut f: [[u64; 20]; 20] = [[0; 20]; 20];
  for x in 0..20 {
    f[x][0] = x as u64 + 2;
    f[0][x] = x as u64 + 2;
  }
  for x in 1..20 {
    for y in 1..(x + 1) {
      f[x][y] = f[x - 1][y] + f[x][y - 1];
      f[y][x] = f[y - 1][x] + f[y][x - 1];
    }
  }
  println!("{}", f[20 - 1][20 - 1]);
}
```

讲真这样比 C++ 还要难看……

### Haskell

```haskell
main = print $ cal 20 20
  where cal x y
          | x == 1 || y == 1 = toInteger $ x + y
          | x == y = 2 * mcal (x - 1) y
          | otherwise = mcal (x - 1) y + mcal x (y - 1)
        mcal x y
          | x < y = mcal y x
          | otherwise = mcall !! (x - 1) !! (y - 1)
        mcall = [[cal x y | y <- [1..x]] | x <- [1..20]]
```

这是一个很简单的枚举，用了记忆化来提高效率。

### 数学！

这是解决这个问题的公式：

$$\frac {2N!} {N! ^ 2}$$

这个方法来自 [这个问题的讨论页面](https://projecteuler.net/thread=15)（你必须要在 [欧拉计划官网](https://projecteuler.net/) 上解决了这个问题才能进入这个页面）。

## 总结

这次的两道题最后看起来都比预想的要简单。下次做欧拉计划的题目要选难度更高一点的题目了。

## 测试环境

- 操作系统：x86_64 Linux 4.10.13-1-ARCH
- Rust 编译环境：rustc 1.19.0-nightly (afa1240e5 2017-04-29)
- Haskell 编译环境：ghc 8.0.2

Frank 提供的程序均未经过测试。

## 下期预告

下期还是做欧拉计划的题：[Problem 68 Magic 5-gon ring](https://projecteuler.net/problem=68) 和 [Problem 79 Passcode derivation](https://projecteuler.net/problem=79)，感兴趣的读者可以写别的语言的版本然后在 Github 上的 [Issues 页面](https://github.com/Problem233/blog/issues) 提交你的答案~
