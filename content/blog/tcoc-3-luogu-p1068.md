---
title: TCOC003 分数线划定
date: 2017-04-08
tags:
  - 编程
  - the Collision of Code
toc: true
---

这里是新的一期 TCOC！上一周没有更新是因为我正在重装系统，所以没什么时间来更新。本期只做一道题（我 OI 水平太低，做这种难度的题就已经很累了，况且还要写这么多个版本）：[「分数线划定」](https://www.luogu.org/problem/show?pid=1068)。

<!-- more -->

> 题目描述：世博会志愿者的选拔工作正在 A 市如火如荼的进行。为了选拔最合适的人才，A 市对所有报名的选手进行了笔试，笔试分数达到面试分数线的选手方可进入面试。面试分数线根据计划录取人数的 150% 划定，即如果计划录取m名志愿者，则面试分数线为排名第 $m \times 150\%$（向下取整）名的选手的分数，而最终进入面试的选手为笔试成绩不低于面试分数线的所有选手。现在就请你编写程序划定面试分数线，并输出所有进入面试的选手的报名号和笔试成绩。
>
> 输入输出格式：
>
> 输入格式：第一行，两个整数 $n, m (5 \leq n \leq 5000, 3 \leq m \leq n)$，中间用一个空格隔开，其中 $n$ 表示报名参加笔试的选手总数，$m$ 表示计划录取的志愿者人数。输入数据保证 $m \times 150\%$ 向下取整后小于等于 $n$。第二行到第 $n + 1$ 行，每行包括两个整数，中间用一个空格隔开，分别是选手的报名号 $k (1000 \leq k \leq 9999)$ 和该选手的笔试成绩 $s (1 \leq s \leq 100)$。数据保证选手的报名号各不相同。
>
> 输出格式：第一行，有两个整数，用一个空格隔开，第一个整数表示面试分数线；第二个整数为进入面试的选手的实际人数。从第二行开始，每行包含两个整数，中间用一个空格隔开，分别表示进入面试的选手的报名号和笔试成绩，按照笔试成绩从高到低输出，如果成绩相同，则按报名号由小到大的顺序输出。

## C++

我不会告诉你们这个程序我写了两个多小时……

```cpp
#include <iostream>
#include <algorithm>

using namespace std;

struct Volunteer {
  int k; // 编号
  int s; // 分数
};

int main() {
  int m, n; // m 选手总数；n 录取人数
  cin >> m >> n;
  int intervs = n * 1.5; // 分数线选手排名
  Volunteer vols[m];
  for(int i = 0; i < m; i++)
    cin >> vols[i].k >> vols[i].s;
  sort(vols, vols + m, [](Volunteer v1, Volunteer v2) {
    if(v1.s == v2.s) return (v1.k < v2.k);
    else return (v1.s > v2.s);
  });
  while(vols[intervs - 1].s == vols[intervs].s) intervs++;
  cout << vols[intervs - 1].s << ' ' << intervs << endl;
  for(int i = 0; i < intervs; i++)
    cout << vols[i].k << ' ' << vols[i].s << endl;
  return 0;
}
```

## Scala

感觉这道题不管在什么语言里写法都差不多……

```scala
import java.util.Scanner

object Main extends App {
  val input = new Scanner(System.in)
  val m = input.nextInt()
  val n = input.nextInt()
  val sr = (n * 1.5).toInt // 分数线选手排名
  case class Volunteer(k: Int, s: Int)
  val vols =
    (0 to (m - 1)).map(_ => Volunteer(input.nextInt(), input.nextInt())) // 读选手数据
                  .sortWith((v1, v2) =>
                    if (v1.s == v2.s) v1.k < v2.k else v1.s > v2.s) // 排序
  val com = vols(sr).s // 分数线
  val intervs = vols takeWhile (v => v.s >= com) // 面试者
  println(com + " " + intervs.length)
  intervs foreach (v => println(v.k + " " + v.s))
}
```

## Haskell

Haskell 里最蛋疼的仍然是 IO……

```haskell
import Control.Monad (forM)
import Data.List (sortBy)

main :: IO ()
main = do
  [m, n] <- gets :: IO [Integer]
  vols <- (sortBy cmp . map (\[k, s] -> Vol k s)) <$>
    forM [1..m] (const gets)
  let sr = fromInteger $ floor (fromInteger n * 1.5)
      com = s $ vols !! sr
      intervs = takeWhile ((>= com) . s) vols
   in do
      puts [com, toInteger $ length intervs]
      forM intervs $ \v -> puts [k v, s v]
  return ()

data Volunteer = Vol { k :: Integer, s :: Integer}

cmp :: Volunteer -> Volunteer -> Ordering
cmp (Vol k1 s1) (Vol k2 s2)
  | s1 == s2  = compare k1 k2
  | otherwise = compare s2 s1

puts :: Show a => [a] -> IO () -- 写一行同类型数据
puts = putStrLn . unwords . map show

gets :: Read a => IO [a] -- 读一行同类型数据
gets = fmap read <$> fmap words getLine
```

基本上和 Scala 版没有区别（虽然看起来区别很大）。

## 总结

从这一期的代码来看，各个语言在解决这类问题时通常不会表现出很大的区别。或许在 Scala、Haskell 中还有这题更简单的解法，这个就只能靠有 dalao 来指点了。

## 测试环境

- 操作系统：x86_64 Linux 4.10.8-1-ARCH
- C++ 编译环境：GCC 6.3.1
- Scala 编译环境：Scala 2.12.1
- Haskell 编译环境：GHC 8.0.2

## 下期预告

下一期的题目是 [欧拉计划](https://projecteuler.net/) 的 [Problem 11 Largest product in a grid](https://projecteuler.net/problem=11)，感兴趣的读者可以写别的语言的版本然后在 Github 上的 [Issues 页面](https://github.com/parorezo/blog/issues) 提交你的答案~
