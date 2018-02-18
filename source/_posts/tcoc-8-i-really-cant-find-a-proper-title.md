---
title: TCOC008 我真的找不出一个好标题了
date: 2017-05-20
tags:
  - 开发
  - the Collision of Code
toc: true
---

这一期 TCOC 的题目采用了 [Codewars](https://www.codewars.com/) 上的 [Diophantine Equation](https://www.codewars.com/kata/diophantine-equation) 和 [Is my friend cheating?](https://www.codewars.com/kata/is-my-friend-cheating)。这两道题也并不是很难，其中的 Is my friend cheating? 需要一些小技巧才能解决。

<!-- more -->

由于 Codewars 的题目描述太长，所以请点进原文查看题目。

## Codewars: Diophantine Equation

这一题还是很简单的。

### C++

```cpp
#include <vector>
#include <utility>
#include <cmath>

using namespace std;

class Dioph {
  public:
    static vector<pair<long, long>> solEquaStr(long long n) {
      vector<pair<long, long>> r;
      for(long i = 1; i <= (long) sqrt(n); i++) {
        if(n % i == 0) {
          long j = n / i;
          if((j - i) % 4 == 0) {
            long y = (j - i) / 4;
            long x = i + 2 * y;
            r.push_back({x, y});
          }
        }
      }
      return r;
    }
};
```

### Rust

```rust
pub fn diophantine_equation(n: i64) -> Vec<(i32, i32)> {
  let mut r: Vec<(i32, i32)> = Vec::new();
  for i in 1..((n as f64).sqrt() as i64) {
    if n % i == 0 {
      let j = n / i;
      if (j - i) % 4 == 0 {
        let y = (j - i) / 4;
        let x = i + 2 * y;
        r.push((x as i32, y as i32));
      }
    }
  }
  r
}
```

### Haskell

```haskell
solequa :: Integer -> [(Integer, Integer)]
solequa n = [(a, b) | x <- [1..truncate $ sqrt $ fromIntegral n],
                      n `mod` x == 0,
                      let ndx = n `div` x,
                      (ndx - x) `mod` 4 == 0,
                      let b = (ndx - x) `div` 4
                          a = x + 2 * b]
```

这是我第一次感觉 List comprehension 这么好用。

## Codewars: Is my friend cheating?

这一题一开始我想用暴力方法枚举出来，然而超时。暴力枚举的时间复杂度为 $O(n ^ 2)$，要用点小技巧把时间复杂度降到 $O(n)$ 才能通过。

### C++

```cpp
#include <vector>

using namespace std;

long long ceildiv(long long a, long long b) {
  return (a - 1) / b + 1;
}

class RemovedNumbers {
  public:
    static vector<vector<long long>> removNb(long long n) {
      vector<vector<long long>> r;
      long long sum = (1 + n) * n / 2;
      long long min = ceildiv(n * (n - 1), (2 * (n + 1)));
      for(long long x = min; x <= n; x++)
        if((sum - x) % (x + 1) == 0)
          r.push_back({x, (sum - x) / (x + 1)});
      return r;
    }
};
```

### Rust

```rust
pub fn is_my_friend_cheating(n: i64) -> Vec<(i64, i64)> {
  fn ceildiv(a: i64, b: i64) -> i64 {
    (a - 1) / b + 1
  }
  let mut r: Vec<(i64, i64)> = Vec::new();
  let sum = (1 + n) * n / 2;
  let min = ceildiv(n * (n - 1), (2 * (n + 1)));
  for x in min..n + 1 {
    if (sum - x) % (x + 1) == 0 {
      r.push((x, (sum - x) / (x + 1)));
    }
  }
  r
}
```

### Haskell

```haskell
removNb :: Integer -> [(Integer, Integer)]
removNb n = [(x, y) | x <- [min..n],
                      (sum - x) `mod` (x + 1) == 0,
                      let y = (sum - x) `div` (x + 1)]
  where sum = (1 + n) * n `div` 2
        min = let fn = fromIntegral n
               in ceiling $ fn * (fn - 1) / (2 * (fn + 1))
```

## 总结

这次似乎……没什么可总结的。那就跳过吧。

## 测试环境

- 操作系统：x86_64 Linux 4.10.13-1-ARCH
- C++ 编译环境：Clang 4.0.0
- Rust 编译环境：rustc 1.19.0-nightly (afa1240e5 2017-04-29)
- Haskell 编译环境：GHC 8.0.2

另外 C++ 和 Haskell 版本的程序均在 Codewars 平台上测试通过。

## 下期预告

~~下期的题目是 [Vijos](https:/vijos.org/) 上的 [清帝之惑之顺治](https://vijos.org/p/1011) 和 [清帝之惑之康熙](https://vijos.org/p/1009)，感兴趣的读者可以写别的语言的版本然后在 Github 上的 [Issues 页面](https://github.com/Problem233/blog/issues) 提交你的答案~~~

我又考虑了一下，就目前的状态来看，各个语言的题目解法并没有太大区别，所以这个系列也就没有意义了。因此，这个系列到这一期就结束了。不过题目我还是会继续做下去的，只不过不会以这种形式了。
