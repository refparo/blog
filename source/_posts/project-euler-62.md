---
title: Project Euler 欧拉计划 62 Cubic permutations 解题记录
date: 2017-06-13
tags:
  - 编程
  - Project Euler
  - Haskell
---

立方数 41063625（$345 ^ 3$）可以重排为另外两个立方数：56623104（$384 ^ 3$）和 66430125（$405 ^ 3$）。实际上，41063625 是重排中恰好有三个立方数的最小立方数。

求重排中恰好有五个立方数的最小立方数。

题目转载于 [pe-cn.github.io](https://pe-cn.github.io/62/)，英文原站：[projecteuler.org](https://projecteuler.net/problem=62)。

## 算法

就是暴力搜索。记录下每种重排的出现次数，最先到达 5 次的就是结果。

## 代码

Github：[ProjectEuler.hs](https://github.com/Problem233/sandbox/blob/cc661ed3045584da9f7e64549469d275a50d6c1f/src/ProjectEuler.hs#L271)

```haskell
answer62_1 :: String
answer62_1 = search 0 1 [] cubes
  where -- 立方数的列表
        -- :: [(String, 原立方数
        --      String)] 排序后的立方数
        cubes = [(c, sort c) | x <- [1..], let c = show $ x * x * x]
        -- 搜索函数
        -- :: Int 立方数的位数
        -- -> [(String, String, Integer)] 保存搜索结果
        -- -> [(String, String)] 立方数列表
        -- -> String 答案
        search x l cs @ ((n, c) : r)
          -- 若立方数位数增加，清空搜索结果再继续
          | length c > x = search (x + 1) [] cs
          -- 否则把当前立方数加入搜索结果
          | otherwise = let (nl, t, nr) = add c n l []
                         in -- 若当前处理的立方数的重排已出现 5 次，
                            -- 则返回这个立方数的最小重排
                            if t == 5 then nr
                            -- 否则继续搜索
                            else search x nl r
        -- 处理搜索结果
        -- :: String 排序好的立方数
        -- -> String 原立方数
        -- -> [(String, String, Integer)] 原搜索结果
        -- -> [(String, String, Integer)] 新的搜索结果
        -- -> ([(String, String, Integer)], 处理完成的搜索结果
        --     Integer, 当前处理的立方数的重排的出现次数
        --     String) 当前处理的立方数的最小立方数重排
        add c n ((tu @ (c', n', t)) : r) res
          -- 若当前处理的立方数的重排已出现过，
          -- 则在搜索结果中把记录的出现次数加 1，返回结果
          | c == c' = (r ++ (c', n', t + 1) : res, t + 1, n')
          | otherwise = add c n r (tu : res)
        -- 若当前处理的立方数的重排是第一次出现，
        -- 则在搜索结果中加入这一记录，返回结果
        add c n [] res = ((c, n, 1) : res, 1, "")
```
