---
title: TCOC006 补充：用 Haskell 优雅地生成杨辉三角
date: 2017-05-12
tags:
  - 编程
  - the Collision of Code
---

这几天又想了一下上一期 TCOC 中的第二题 [欧拉计划 Problem 15 Lattice paths](/posts/tcoc-6-two-interesting-math-problems/#%E6%AC%A7%E6%8B%89%E8%AE%A1%E5%88%92-Problem-15-Lattice-paths)。突然想到，由于 Haskell 的惰性，所以我就可以用一种非常优雅的方式来生成杨辉三角：

```haskell
pascalsTriangle :: Integral a => [[a]]
pascalsTriangle = generate $ repeat 1
  where generate xs = xs : generate (generateRaw 1 $ tail xs)
        generateRaw l (u : r) = let n = l + u
                                  in l : generateRaw n r
```

于是这一题就可以这样做：

```haskell
main :: IO ()
main = print (pascalsTriangle !! 20 !! 20)
```

无比简单优雅！

从这里就可以看出，Haskell 里的无限列表在解决这类数学问题时是非常好用的，以后这类问题可以多从这个方向思考。

## 测试环境

- 操作系统：x86_64 Linux 4.10.13-1-ARCH
- Haskell 编译环境：ghc 8.0.2
