---
title: 在 Typescript 中模拟高阶类型
date: 2019-09-08
tags:
  - 编程
  - Typescript
toc: true
---

*高阶类型*（*Higher Kinded Types*）对我这个 PL 爱好者来说，几乎是必备的语言特性了。Typescript 是我主要使用的语言之一，它虽然不直接支持高阶类型，但利用它本身已经比较强大的类型系统，是可以模拟出高阶类型的。

<!-- more -->

为了照顾不了解高阶类型的读者，下面先简要介绍一下：

## 高阶类型是什么

大部分现代语言都已经支持高阶函数。“高阶类型”和“高阶函数”都有“高阶”二字，它们分别与“类型”、“函数”之间的关系也非常相似。众所周知，一切表达式都有类型：`a: A`，而函数作为表达式，也具有它的类型：`f: A -> B`。而高阶函数，就是参数的类型为函数的函数：`higher: (A -> B) -> C`。

与之相似，类型也有类型，我们把类型的类型称作*阶*（*Kind*）。普通的类型的阶是 `Type`，即 `A: Type`；有类型参数的类型类似于函数，它们的阶则是 `F: Type -> Type`。那么，高阶类型就是参数的阶不是 `Type` 的类型：`Higher: (Type -> Type) -> Type`。如果在 Typescript 里表示就是这样：

```typescript
type A = unknown
type F<T> = T
type Higher<F> = F<A>
```

Typescript 并不支持这种语法，因此下面我们就要用 Typescript 已有的特性来模拟这一功能。

## 模拟高阶类型

首先假设我们有这样两个类型：

```typescript
interface F<A> {
  value: A
}
declare enum A {}
```

要模拟高阶类型，我们需要想办法构造出这样的结构：

```typescript
type $<F, T> = unknown

type Test0 = $<F, A> // => { value: A }
```

但直接用 `F` 作类型参数显然是不可能的。因此我们需要用某种类型来代替 F 作为 `$` 的类型参数：

```typescript
interface Repr {
  type: unknown
}
type $<F extends Repr, T> = F["type"]

interface FRepr extends Repr {
  type: F</* ??? */>
}
type Test1 = $<FRepr, A> // => { value: A }
```

但是这样一来，`FRepr` 如何获得 `F` 的类型参数呢？可以利用 Typescript 中的 `this` 类型：

```typescript
interface Repr {
  type: unknown
  typeArgs: unknown
}
type $<F extends Repr, T> = (F & { typeArgs: T })["type"]

interface FRepr extends Repr {
  type: F<this["typeArgs"]>
}
type Test2 = $<FRepr, A> // => { value: A }
```

这样似乎已经达到了我们的目的。但是实际使用中可以发现一个致命的缺陷：

```typescript
declare const f: <F extends Repr, T>(x: $<F, T>): $<F, string>
declare const x: F<number>
const y = f(x) // : unknown
```

在这个例子中，Typescript 推导不出 `y` 的类型。这是因为 Typescript 无法通过 `F` 找到它对应的 `FRepr`。因此需要在类型 `F` 中作一个标记指向它的 `Repr`：

```typescript
namespace Generic {
  export declare const repr: unique symbol
}
type AppliedRepr<R, T> = R & { typeArgs: T }
interface HasGeneric<R, T> {
  [Generic.repr]: AppliedRepr<R, T>
}

interface F<T> extends HasGeneric<FRepr, T> {
  value: T
}
```

然后修改我们的 `$` 定义来辅助类型推导：

```typescript
type $<R, T> = R extends Repr
             ? AppliedRepr<R, T>["type"]
             : HasGeneric<R, T>

interface FRepr extends Repr {
  type: F<this["typeArgs"]>
}
declare function f <F, A>(x: $<F, A>): $<F, string>
declare const x: F<number>
const y = f(x) // : F<string>
```

这样，我们模拟的高阶类型就完成了。

## 实际应用

高阶类型很常见的一种用途就是用来表示像 Functor 这样的概念。在 Haskell 中，Functor 类型类的定义是这样的：

```haskell
class Functor (f :: * -> *) where
  fmap :: (a -> b) -> f a -> f b
```

这里 `Functor` 就接受了一个阶为 `Type -> Type` 类型构造器。而要在 Typescript 里描述这个类型类，就要这样写：

```typescript
interface Functor<FR> {
  fmap: <T, U>(f: (x: T) => U) => (a: $<FR, T>) => $<FR, U>
}

// 实现一个 Functor
interface Array<T> extends HasGeneric<ArrayRepr, T> {}
interface ArrayRepr extends Repr {
  type: Array<this["typeArgs"]>
}
const functorArray: Functor<ArrayRepr> = {
  fmap: f => xs => xs.map(x => f(x))
}
```

至于更多的用途，那就要靠你自己探索了。

## 参数限制与多参类型构造器

对于参数带有限制的类型构造器，我们可以在对应的 `Repr` 中用条件类型来筛选从 `$` 传来的类型参数：

```typescript
interface G<T extends string> extends HasGeneric<GRepr, T> {}
interface GRepr extends Repr {
  type: this["typeArgs"] extends string ? G<this["typeArgs"]> : never
}
```

对于多参的类型构造器，可以用元组类型来保存每个参数：

```typescript
interface H<T, U> extends HasGeneric<HRepr, [T, U]> {}
interface HRepr extends Repr {
  type: this["typeArgs"] extends [infer T, infer U] ? H<T, U> : never
}
```

## 完整实现

```typescript
interface Repr {
  type: unknown
  typeArgs: unknown
}
type $<R, T> = R extends Repr
            ? AppliedRepr<R, T>["type"]
            : HasGeneric<R, T>

namespace Generic {
  export declare const repr: unique symbol
}
type AppliedRepr<R, T> = R & { typeArgs: T }
interface HasGeneric<R, T> {
  [Generic.repr]: AppliedRepr<R, T>
}
```

本文的实现思路来源于 [strax/tshkt](https://github.com/strax/tshkt)。
