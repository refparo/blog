---
title: TCOC007 更难的数学题
date: 2017-05-13
tags:
  - 编程
  - the Collision of Code
toc: true
---

如 [上期结尾](/posts/tcoc-6-two-interesting-math-problems/#%E4%B8%8B%E6%9C%9F%E9%A2%84%E5%91%8A) 所述，这次我要做更难一些的题目。这次的题目是欧拉计划上的 [Problem 68 Magic 5-gon ring](https://projecteuler.net/problem=68) 和 [Problem 79 Passcode derivation](https://projecteuler.net/problem=79)。

<!-- more -->

## 欧拉计划 Problem 68 Magic 5-gon ring

考虑下面这个「魔力」三角形环，在其中填入 1 至 6 这 6 个数，每条线上的三个数加起来都是 9。

![「魔力」三角形环](https://projecteuler.net/project/images/p068_1.gif)

从最外侧结点所填的数最小的线（在这个例子中是 4,3,2）开始，按**顺时针**方向，每个解都能被唯一表述。例如，上面这个解可以记作解集：4,3,2; 6,2,1; 5,1,3。

将环填满后，每条线上的总和一共有四种可能：9、10、11 和 12。总共有 8 种填法：

| 总和 | 解集 |
| - | - |
| 9 | 4,2,3; 5,3,1; 6,1,2 |
| 9 | 4,3,2; 6,2,1; 5,1,3 |
| 10 | 2,3,5; 4,5,1; 6,1,3 |
| 10 | 2,5,3; 6,3,1; 4,1,5 |
| 11 | 1,4,6; 3,6,2; 5,2,4 |
| 11 | 1,6,4; 5,4,2; 3,2,6 |
| 12 | 1,5,6; 2,6,4; 3,4,5 |
| 12 | 1,6,5; 3,5,4; 2,4,6 |

把解集中的数字连接起来，可以构造一个 9 位数字串；对于三角形环来说，最大的数字串是 432621513。

在如下的「魔力」五边形环中，在其中填入 1 至 10 这 10 个数，根据不同的填写方式，可以组成 16 位或 17 位数字串。在「魔力」五边形环中，最大的 **16 位**数字串是多少？

![「魔力」五边形环](https://projecteuler.net/project/images/p068_2.gif)

### 思路

这个思路来源于 [这篇文章](http://blog.csdn.net/youb11/article/details/46917489)。

首先，题目中说解从最外侧节点所填的数最小的线开始，同时又要让解集中的数字连接起来的数字最大，这就说明解的第一个数字必是 6，其余的数字则分别是 7，8，9，10，剩下的 1，2，3，4，5 则都在内圈。由于内圈的数在解集中一共会出现 2 次，所以每一条线上的和就是 $(2 \times (1 + 2 + 3 + 4 + 5) + 6 + 7 + 8 + 9 + 10) \div 5 = 14$。所以，6 所在的那一行其余两个数的和为 8。因为 7 在外圈，所以排除 1 和 7，又因为不能重复，排除 2 和 6、4 和 4，所以只能是 3 和 5。又因为要让数字串最大，所以应让 5 排在前面，于是这个五边形中这些格子就已经确定了：

![部分完成的五边形环](partially-completed-5-gon-ring.png)

剩下的用程序枚举出来就行。

### C++

```cpp
#include <iostream>
#include <algorithm>

using namespace std;

int main() {
  int o[] = {7, 8, 9, 10};
  int i[] = {1, 2, 4};
  do {
    do {
      if(o[0] + 3 + i[0] == 14 && o[1] + i[0] + i[1] == 14 &&
         o[2] + i[1] + i[2] == 14 && o[3] + i[2] + 5 == 14)
        cout << 6 << 5 << 3 << o[0] << 3 << i[0]
             << o[1] << i[0] << i[1] << o[2] << i[1] << i[2]
             << o[3] << i[2] << 5 << endl;
    } while(next_permutation(i, i + 3));
  } while(next_permutation(o, o + 4));
  return 0;
}
```

### Rust

注：由于我懒得自己写全排列，所以这里需要加入一个 *crate* 依赖：[permutohedron 0.2.2](https://crates.io/crates/permutohedron)。

```rust
extern crate permutohedron;

use permutohedron::heap_recursive;

pub fn main() {
  let mut o = [7, 8, 9, 10];
  let mut i = [1, 2, 4];
  heap_recursive(&mut o, |po| heap_recursive(&mut i, |pi| {
    if po[0] + 3 + pi[0] == 14 && po[1] + pi[0] + pi[1] == 14 &&
       po[2] + pi[1] + pi[2] == 14 && po[3] + pi[2] + 5 == 14 {
      println!("{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}",
        6, 3, 5, po[0], 3, pi[0], po[1], pi[0], pi[1],
        po[2], pi[1], pi[2], po[3], pi[2], 5);
    }
  }));
}
```

### Haskell

```haskell
import Data.List (permutations)

main :: IO ()
main = putStrLn $
       concatMap (concatMap show . (\([o1, o2, o3, o4], [i1, i2, i3]) ->
         [6, 5, 3, o1, 3, i1, o2, i1, i2, o3, i2, i3, o4, i3, 5])) $
       filter (\([o1, o2, o3, o4], [i1, i2, i3]) ->
                o1 + 3 + i1 == 14 && o2 + i1 + i2 == 14 &&
                o3 + i2 + i3 == 14 && o4 + i3 + 5 == 14)
              [(o, i) | o <- permutations [7, 8, 9, 10],
                        i <- permutations [1, 2, 4]]
```

这个枚举在各个语言中都没有什么区别。

## 欧拉计划 Problem 79 Passcode derivation

网上银行常用的一种密保手段是向用户询问密码中的随机三位字符。例如，如果密码是 531278，询问第 2、3、5 位字符，正确的答案应当是 317。

在文本文件 [keylog.txt](https://projecteuler.net/project/resources/p079_keylog.txt) 中包含了 50 次成功登陆的正确回复。

假设三个字符总是按顺序询问的，分析这个文本文件，给出这个未知长度的密码最短的一种可能。

这里为了偷懒，我就直接从标准输入读了。另外我先粗略地看了一下这个记录，确认不需要出现重复数字。

### C++

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
  string kl[50];
  char apps[] = "0123456789";
  for(int i = 0; i < 50; i++) {
    cin >> kl[i];
    apps[kl[i][0] - 48] = apps[kl[i][1] - 48] = apps[kl[i][2] - 48] = 'x';
  }
  vector<char> r;
  for(int j = 0; j < 10; j++)
    if(apps[j] == 'x') r.push_back(j + 48);
  sort(r.begin(), r.end(), [&kl] (const char &a, const char &b) {
    for(int i = 0; i < 50; i++)
      if(b == kl[i][0] && (a == kl[i][1] || a == kl[i][2]) ||
         b == kl[i][1] && a == kl[i][2]) return false;
    return true;
  });
  for(vector<char>::iterator it = r.begin(); it != r.end(); it++)
    cout << *it;
  cout << endl;
}
```

### Rust

我实在想不出怎么用 Rust 这个鬼畜的语言来写这个程序……

### Haskell

```haskell
import Control.Monad (forM)
import Data.List (nub, sortBy)

main :: IO ()
main = do
  kl <- forM [1..50] (const getLine)
  putStrLn $ sortBy (\c1 c2 ->
    foldl (\o [a, b, c] ->
            if c2 == a && (c1 == b || c1 == c) || c2 == b && c1 == c
            then GT else o)
          LT kl) $ nub $ concat kl
```

和 C++ 版本是一样的套路，但是短了很多呢（用标准库作弊）。

## 彩蛋！[欧拉计划 Problem 97 Large non-Mersenne prime](https://projecteuler.net/problem=97)

我发现了一道题号大，但炒鸡简单的题目！

1999 年人们发现了第一个超过一百万位的素数，这是一个梅森素数，可以表示为 $2 ^ 6972593 − 1$，包含有 2,098,960 位数字。在此之后，更多形如 $2 ^ p − 1$ 的梅森素数被发现，其位数也越来越多。

然而，在 2004 年，人们发现了一个巨大的非梅森素数，包含有 2,357,207 位数字：$28433 \times 2 ^ 7830457 + 1$。

找出这个素数的最后十位数字。

### Haskell

```haskell
main :: IO ()
main = print $ (28433 * 2 ^ 7830457 + 1) `mod` 10000000000
```

就是这么简单！Haskell 自带高精度计算！

## 总结

这一期的题目都不怎么能体现出语言之间的区别，除了丧心病狂的 Rust 让我根本写不出 P79……

## 测试环境

- 操作系统：x86_64 Linux 4.10.13-1-ARCH
- C++ 编译环境：Clang 4.0.0
- Rust 编译环境：rustc 1.19.0-nightly (afa1240e5 2017-04-29)
- Haskell 编译环境：GHC 8.0.2

## 下期预告

下一期我想做两道 [Codewars](https://www.codewars.com/) 上难度为 5 kyu 的题目：[Diophantine Equation](https://www.codewars.com/kata/diophantine-equation) 和 [Is my friend cheating?](https://www.codewars.com/kata/is-my-friend-cheating)，感兴趣的读者可以写别的语言的版本然后在 Github 上的 [Issues 页面](https://github.com/Problem233/blog/issues) 提交你的答案~
