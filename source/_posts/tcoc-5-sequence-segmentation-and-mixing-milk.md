---
title: TCOC005 数列分段与混合牛奶
date: 2017-04-29
tags:
  - 编程
  - the Collision of Code
toc: true
---

这一次做的是两道简单的贪心题： [「数列分段」](https://www.luogu.org/problem/show?pid=1181) 和 [「混合牛奶」](https://www.luogu.org/problem/show?pid=1208)。这种题目目测不管是哪种语言写法都不会有很大区别，所以这里就不再使用 Scala 来解题了。

<!-- more -->

## 洛谷 P1181 数列分段

> 题目描述：对于给定的一个长度为 $N$ 的正整数数列 $\{A_i\}$，现要将其分成连续的若干段，并且每段和不超过 $M$（可以等于 $M$），问最少能将其分成多少段使得满足要求。
>
> 输入输出格式：
>
> 输入格式：输入文件 `divide_a.in` 的第 1 行包含两个正整数 $N$，$M$，表示了数列 $\{A_i\}$ 的长度与每段和的最大值，第2行包含N个空格隔开的非负整数 $\{A_i\}$，如题目所述。
>
> 输出格式：输出文件 `divide_a.out` 仅包含一个正整数，输出最少划分的段数。

### C++

```cpp
#include <iostream>

using namespace std;

int main() {
  int n, m;
  cin >> n >> m;
  int sum = 0;
  int s = 0;
  int i;
  while(n > 0) {
    cin >> i;
    if(sum + i <= m) sum += i;
    else {
      sum = i;
      s++;
    }
    n--;
  }
  s++;
  cout << s << endl;
  return 0;
}
```

简单的不能再简单。

### Haskell

解法应该和 C++ 没什么区别。

```haskell
main :: IO ()
main = do
  [_, m] <- gets -- 对于 Haskell，这个 n 是没用的
  (_, s) <-
    let fold = foldl (\(sum, s) i ->
                        if sum + i <= m
                        then (sum + i, s)
                        else (i, s + 1))
                     (0, 0)
     in fmap fold gets
  print (s + 1)

gets :: Read a => IO [a]
gets = fmap read <$> fmap words getLine
```

讲真可读性也降低了。

## 洛谷 P1208 混合牛奶

> 题目描述：
>
> 由于乳制品产业利润很低，所以降低原材料（牛奶）价格就变得十分重要。帮助 Marry 乳业找到最优的牛奶采购方案。
>
> Marry 乳业从一些奶农手中采购牛奶，并且每一位奶农为乳制品加工企业提供的价格是不同的。此外，就像每头奶牛每天只能挤出固定数量的奶，每位奶农每天能提供的牛奶数量是一定的。每天 Marry 乳业可以从奶农手中采购到小于或者等于奶农最大产量的整数数量的牛奶。
>
> 给出 Marry 乳业每天对牛奶的需求量，还有每位奶农提供的牛奶单价和产量。计算采购足够数量的牛奶所需的最小花费。
>
> 注：每天所有奶农的总产量大于 Marry 乳业的需求量。
>
> 输入输出格式：
>
> 输入格式：
>
> 第 1 行共二个数值：$N (0 \leq N \leq 2000000)$ 是需要牛奶的总数；$M (0 \leq M \leq 5000)$ 是提供牛奶的农民个数。
>
> 第 2 到 $M + 1$ 行：每行二个整数：$P_i$ 和 $A_i$。$P_i (0 \leq P_i \leq 1000)$ 是农民 $i$ 的牛奶的单价。$A_i (0 \leq A_i \leq 2000000)$ 是农民 $i$ 一天能卖给 Marry 乳业的牛奶数量。
>
> 输出格式：
>
> 单独的一行包含单独的一个整数，表示 Marry 乳业拿到所需的牛奶所要的最小费用。

### C++

```cpp
#include <iostream>
#include <algorithm>

using namespace std;

struct Farmer {
  int p;
  int a;
};

int main() {
  int n, m;
  cin >> n >> m;
  Farmer f[m];
  for(int i = 0; i < m; i ++)
    cin >> f[i].p >> f[i].a;
  sort(f, f + m, [](Farmer f1, Farmer f2) {
    return (f1.p < f2.p);
  });
  int v = 0;
  for(int i = 0; n > 0; i ++)
    if(n >= f[i].a) {
      v += f[i].p * f[i].a;
      n -= f[i].a;
    } else {
      v += f[i].p * n;
      n = 0;
    }
  cout << v << endl;
  return 0;
}
```

这题真水……

### Haskell

```haskell
import Control.Monad (forM)
import Data.List (sortOn)

main :: IO ()
main = do
  [n, m] <- gets
  f <- (sortOn fst . map (\[p, a] -> (p, a))) <$>
         forM [1..m] (const gets)
  let fold v 0    _ = v
      fold v need ((p, a) : fs)
        | need >= a = fold (v + p * a) (need - a) fs
        | otherwise = fold (v + p * need) 0 fs
   in print $ fold 0 n f

gets :: Read a => IO [a]
gets = fmap read <$> fmap words getLine
```

根本就是完全一样。

## 总结

不同语言的贪心算法写法都大同小异，不存在什么很大的区别。

## 测试环境

- 操作系统：x86_64 Linux 4.10.11-1-ARCH
- C++ 编译环境：Clang 4.0.0 + GCC 6.3.1
- Haskell 编译环境：GHC 8.0.2

## 下期预告

下一期的题目是 [欧拉计划](https://projecteuler.net/) 的 [Problem 9 Special Pythagorean triplet](https://projecteuler.net/problem=9) 和 [Problem 15 Lattice paths](https://projecteuler.net/problem=15)，感兴趣的读者可以写别的语言的版本然后在 Github 上的 [Issues 页面](https://github.com/Problem233/blog/issues) 提交你的答案~
