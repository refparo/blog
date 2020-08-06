---
title: Idris 中类型安全的 printf
date: 2018-04-05
tags:
  - 编程
  - Idris
---

从寒假开始，断断续续地玩了两个月 [Idris](http://idris-lang.org/)。最开始让我决定开 Idris 这个坑的还是 [这篇文章](https://www.zhihu.com/question/55342708/answer/148680032) 中的这句话：

> Idris 是极少几种可以实现强类型 printf 的语言。

那么下面就开始利用依赖类型构造一个强类型的 `printf` 函数吧！

<!-- more -->

## `HList`

为了更容易实现强类型 `printf`，我需要实现一个 `HList`（heterogenous list）类型。`HList` 是一种可以包含不同类型元素的列表，其定义类似于 `Vect`（带长度的列表，依赖类型里一般叫作 vector）：

（以后 Idris 源码中都默认带有 `%access public export` 和 `%default total`。）

```idris
data HList : {default Type t : _} -> (ts : List t) -> Type where
  Nil  : HList []
  (::) : a -> HList ts -> HList (a :: ts)
```

它的类型中有一个 `List t` 参数来指定每个元素的类型。在 [我的 Github](https://github.com/paro-zo/sandbox/blob/cd748aeb4dd8153f23b8cae8fb17c35a194c6853/Sandbox/HList.idr) 上还有一些简单函数的定义，但这里只需要这个类型定义就够了。

（[prism.js](https://prismjs.com/) 不支持 Idris，差评……）

## 实现 format 函数

要实现一个简单的类型安全的 format 函数，其第二个参数（格式化数据）的类型要依赖于第一个参数（格式化字符串），因此需要先实现由第一个参数得到第二个参数类型的函数。一开始我是由第一个参数直接得到第二个参数，但不明原因导致编译不过。参考了 Github 上已有的实现以后添加了一个中间类型来表示格式化字符串的解析结果：

```idris
data Fmt = FInt | FInteger | FNat | FDouble | FString | FLiteral Char

toFmt : String -> List Fmt
toFmt = toFmt' . unpack
  where toFmt' ('%' :: c :: r) =
          (:: toFmt' r) $ case c of
            'd' => FInt
            'l' => FInteger
            'u' => FNat
            'e' => FDouble
            's' => FString
            '%' => FLiteral '%'
            _ => assert_unreachable
        toFmt' (c :: r) = FLiteral c :: toFmt' r
        toFmt' [] = []
```

`toFmt` 函数用于把字符串转换为 `Fmt` 类型。由于这个函数只用于类型推导，所以那个 `assert_unreachable` 是没有影响的。

然后就是函数 `formatTy`：

```idris
formatTy : List Fmt -> List Type
formatTy = flip foldr [] $ \fmt => case fmt of
             FInt => (Int ::)
             FInteger => (Integer ::)
             FNat => (Nat ::)
             FDouble => (Double ::)
             FString => (String ::)
             _ => id
```

把这个函数的值喂给 `HList` 就是第二个参数的类型了。（这里函数式的 point-free 技巧用得有点多，希望不影响阅读。）

这样，`formatHList` 函数就很好定义了：

```idris
formatHList : (fmtStr : String) -> HList (formatTy $ toFmt fmtStr) -> String
formatHList fmtStr = formatHList' (toFmt fmtStr)
  where formatHList' : (fmt : List Fmt) -> HList (formatTy fmt) -> String
        formatHList' (FInt :: rFmt) (x :: r) = show x ++ formatHList' rFmt r
        formatHList' (FInteger :: rFmt) (x :: r) = show x ++ formatHList' rFmt r
        (...)
```

下面大段的重复代码被我省略了。这里的重点是函数的类型：第一个参数为 `String` 类型，第二个参数的类型为 `HList (formatTy $ toFmt fmtStr)` 依赖了第一个参数的值。当第一个参数改变，第二个参数所需要的类型也会相应改变。实际的效果就是：当使用者写错了格式化字符串或格式化参数，程序都会编译不过。这就是我们的目的。

## 柯里化

目的达到了，但是注意这个函数接受了一个 `HList` 作为参数列表。这在函数式语言中是非常难看的。由于这里用了 `HList`，所以可以写一个通用的函数来柯里化所有接受 `HList` 作为参数的函数：

```idris
curryHListTy : List Type -> Type -> Type
curryHListTy (t :: r) u = t -> curryHListTy r u
curryHListTy [] u = u

curryHList : (HList ts -> u) -> curryHListTy ts u
curryHList {ts = _ :: _} f = \x => curryHList (\l => f (x :: l))
curryHList {ts = []} f = f []
```

`curryHList` 的第二个参数的类型同样依赖于第一个参数的类型。它接受一个函数，返回一个柯里化的函数。于是之前的 `formatHList` 函数可以用它柯里化成多参数的函数了：

```idris
format : (fmtStr : String) -> curryHListTy (formatTy $ toFmt fmtStr) String
format fmtStr = curryHList $ formatHList fmtStr
```

最后实现 `printfHList` 和 `printf` 函数：

```idris
printfHList : (fmtStr : String) -> HList (formatTy $ toFmt fmtStr) -> IO ()
printfHList fmtStr args = putStr $ formatHList fmtStr args

printf : (fmtStr : String) -> curryHListTy (formatTy $ toFmt fmtStr) (IO ())
printf fmtStr = curryHList $ printfHList fmtStr
```

完成！从这个函数的实现可以窥见类型系统的强大之处。效果：

```idris
*Sandbox> format "hello, %s" "problem233"
"hello, problem233" : String
*Sandbox> format "hello, %s" 1
(input):1:1-20:String is not a numeric type
*Sandbox> format "hello, %s. you're the %uth visitor" "problem233" 20
"hello, problem233. you're the 20th visitor" : String
*Sandbox> format "hello, %s. you're the %uth visitor" "problem233" (-1)
(input):1:1-61:Can't find implementation for Neg Nat
*Sandbox> format "hello, %p" "problem233"
(input):1:1-31:format "hello, %p" does not have a function type (curryHListTy (formatTy (toFmt "hello, %p")) String)
```
