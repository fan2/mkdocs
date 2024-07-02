---
title: C/C++ Memory Alignment
authors:
  - xman
date:
    created: 2021-10-12T14:00:00
    updated: 2024-05-02T12:00:00
categories:
    - CS
    - c
    - cpp
tags:
    - alignment
    - boundary
comments: true
---

One of the low-level features of C/C++ is the ability to specify the precise alignment of objects in memory to take maximum advantage of a specific hardware architecture. By default, the compiler **aligns** class and struct members on their size value.

<!-- more -->

## C alignment

Excerpt from [Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/).

**12 The C memory model | 12.7 Alignment**

The inverse direction of pointer conversions (from “pointer to character type” to “pointer to object”) is not harmless at all, and not only because of possible aliasing. This has to do with another property of C's memory model: ***alignment***. Objects of most non-character types can't start at any *arbitrary* byte position; they usually start at a ***word boundary***. The alignment of a type then describes the possible byte positions at which an object of that type can start.

If we force some data to a false alignment, really bad things can happen.

The program crashes with an error indicated as a ***bus error***, which is a shortcut for something like “data bus alignment error.”

As you can see in the output, above, it seems that `complex double` still works well for alignments of half of its size, but then with an alignment of one fourth, the program crashes.

---

In the previous code example, we also see a new operator, `alignof` (or `_Alignof`, if you don't include [<stdalign.h\>](https://en.cppreference.com/w/c/types)), that provides us with the alignment of a specific type. You will rarely find the occasion to use it in real live code.

Another keyword can be used to force allocation at a specified alignment: `alignas` (respectively, `_Alignas`). Its argument can be either a type or expression. It can be useful where you know that your platform can perform certain operations more efficiently if the data is aligned in a certain way.

## C++ alignment

### ISO/IEC-N4950

20230510 - [ISO/IEC-N4950](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf)

6 Basics | 6.7 Memory and objects | **6.7.6 Alignment**

1. Object types have *alignment requirements* (6.8.2, 6.8.4) which place restrictions on the addresses at which an object of that type may be allocated. An ***alignment*** is an implementation-defined integer value representing the number of bytes between successive addresses at which a given object can be allocated. An object type imposes an alignment requirement on every object of that type; stricter alignment can be requested using the alignment specifier (9.12.2).

2. A *fundamental alignment* is represented by an alignment less than or equal to the greatest alignment supported by the implementation in all contexts, which is equal to `alignof(std::max_align_t)` (17.2). The alignment required for a type may be different when it is used as the type of a complete object and when it is used as the type of a subobject.

    - The result of the `alignof` operator reflects the alignment requirement of the type in the complete-object case.

6. The alignment requirement of a complete type can be queried using an `alignof` expression (7.6.2.6). Furthermore, the narrow character types (6.8.2) shall have the *weakest* alignment requirement.

    - This enables the ordinary character types to be used as the underlying type for an aligned memory area (9.12.2).

---

**related sections**:

- 7 Expressions | 7.6 Compound expressions | 7.6.2 Unary expressions | 7.6.2.6 Alignof
- 9 Declarations | 9.12 Attributes | 9.12.2 Alignment specifier
- 17 Language support library | 17.2 Common definitions | 17.2.4 Sizes, alignments, and offsets

### language support

《[现代C++语言核心特性解析-2021](https://item.jd.com/12942311.html)》 - 第30章 alignas 和 alignof

C++11中新增了 `alignof` 和 `alignas` 两个关键字，其中 `alignof` 运算符可以用于获取类型的对齐字节长度，`alignas` 说明符可以用来改变类型的默认对齐字节长度。这两个关键字的出现解决了长期以来C++标准中无法对数据对齐进行处理的问题。

`alignof` 运算符和前面提到的编译器扩展关键字 `__alignof`、`__alignof__` 用法相同，都是获得类型的对齐字节长度。

C++标准规定 `alignof` 必须是针对类型的。不过 GCC 扩展了这条规则，`alignof` 除了能接受一个类型外还能接受一个变量。使用MSVC的读者如果想获得变量的对齐，不妨使用编译器的扩展关键字 `__alignof`。

另外，还可以通过 `alignof` 获得类型 `std::max_align_t` 的对齐字节长度，这是一个非常重要的值。

C++11 [<stddef.h\>](https://en.cppreference.com/w/c/types) 定义了 `std::max_align_t`，它是一个平凡的标准布局类型，其对齐字节长度要求至少与每个标量类型一样严格。也就是说，所有的标量类型都适应 `std::max_align_t` 的对齐字节长度。

C++ 标准还规定，诸如 `new` 和 `malloc` 之类的分配函数返回的指针需要适合于任何对象，也就是说内存地址至少与 `std::max_align_t` 严格对齐。

由于 C++ 标准并没有定义 `std::max_ align_t` 对齐字节长度具体是什么样的，因此不同的平台会有不同的值，通常情况下是8字节和16字节。
