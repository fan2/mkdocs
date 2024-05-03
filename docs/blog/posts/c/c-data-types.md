---
title: C Data Types
authors:
  - xman
date:
    created: 2009-10-03T12:00:00
categories:
    - c
tags:
    - data_type
comments: true
---

A C program, whatever its size, consists of functions and variables. A function contains statements that specify the computing operations to be done, and variables store values used during the computation.

在 C 程序里，函数（function）就是指令，变量（variable）就是数据。数据类型定义了变量的存储和访问属性，约束了其大小边界（size/boundary）、取值范围（value range）、解释呈现（interpretation/representation）和可操作集（operation set）。

<!-- more -->

## C Concepts

![1999_ISO_C_Concepts](./images/1999_ISO_C_Concepts.png)

## C Program

[C Programming Language(2e)](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/) - Brian W. Kernighan, Dennis M. Ritchie, 1988

1.1 Getting Started

> A C program, whatever its size, consists of functions and variables. A function contains statements that specify the computing operations to be done, and variables store values used during the computation.

1.2 Variables and Arithmetic Expressions

> A declaration announces the properties of variables; it consists of a [type] name and a list of variables.

《[C语言标准与实现](https://att.newsmth.net/nForum/att/CProgramming/3213/245)》姚新颜，2004

> 03 从汇编语言开始：简单地说，一个程序最重要的两个部分分别是数据和对数据进行操作的指令。因此，我们必须要清楚地了解一个程序的数据与指令是如何被组织起来的。
> 08 C 语言的变量：在 C 程序里，变量（variable）就是数据，函数（function）就是指令。

《[汇编语言(4e)](https://item.jd.com/12841436.html)》王爽, 2019

> 1.5 指令和数据：指令和数据是应用上的概念。在内存或磁盘上，指令和数据没有任何区别，都是二进制信息。CPU 在工作的时候把有的信息看作指令，有的信息看作数据，为同样的信息赋予了不同的意义。

## C data types

[C data types](https://en.wikipedia.org/wiki/C_data_types)

In the C programming language, `data types` constitute the semantics and characteristics of *storage* of data elements. They are expressed in the language syntax in form of declarations for memory locations or variables. Data types also **determine** the types of operations or methods of processing of data elements.

The C language provides basic arithmetic types, such as integer and real number types, and syntax to build array and compound types. *Headers* for the [C standard library](https://en.wikipedia.org/wiki/C_standard_library), to be used via include directives, contain definitions of support types, that have additional properties, such as providing storage with an exact size, independent of the language implementation on specific hardware platforms.

C 语言中的基本数据类型: char、short、int、long，float、double。

C 语言包含的数据类型[如图所示](https://item.jd.com/12720594.html)：

![C-data-types](./images/C-data-types.png)

[The GNU C Reference Manual](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html) - [2 Data Types](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Data-Types)

## Type support

[Type](https://en.cppreference.com/w/c/language/type)

- Type classification
- Compatible types
- Composite types
- Incomplete types
- Type names

[Type support](https://en.cppreference.com/w/c/types) - Basic types

- Additional basic types and convenience macros: [<stddef.h\>](https://en.cppreference.com/w/c/types)
- [Fixed width integer types (since C99)](https://en.cppreference.com/w/c/types/integer)

    - Types & Macro constants: <stdint.h\>
    - Format macro constants: <inttypes.h\>

- [Numeric limits](https://en.cppreference.com/w/c/types/limits): <limits.h\>, [<stdint.h\>](https://en.cppreference.com/w/c/types/integer)

    - [Data Type Ranges | Microsoft Learn](https://learn.microsoft.com/en-us/cpp/cpp/data-type-ranges?view=msvc-170)
    - GNU [A.5 Data Type Measurements](http://www.gnu.org/software/libc/manual/html_node/Data-Type-Measurements.html#Data-Type-Measurements) : [Width of an Integer Type](https://www.gnu.org/software/libc/manual/html_node/Width-of-Type.html) & [Range of an Integer Type](https://www.gnu.org/software/libc/manual/html_node/Range-of-Type.html)

## Predefined Macros

GNU C Preprocessor - [Common Predefined Macros](https://gcc.gnu.org/onlinedocs/cpp/Common-Predefined-Macros.html)
[Clang Preprocessor options](https://clang.llvm.org/docs/ClangCommandLineReference.html#preprocessor-options) - [Dumping preprocessor state](https://clang.llvm.org/docs/ClangCommandLineReference.html#id8)

```Shell title="dump prededined macros"
$ echo | cpp -dM
$ echo | gcc -x c -E -dM -
$ echo | g++ -x c++ -E -dM -

# IA32（_ILP32）/IA64（_LP64）
$ clang -x c -E -dM -arch i386 /dev/null
$ clang -x c -E -dM -arch x86_64 /dev/null

# ARM32（_ILP32）/ARM64（_LP64）
$ clang -x c -E -dM -arch armv7s /dev/null
$ clang -x c -E -dM -arch arm64 /dev/null
```

GNU [Layout of Source Language Data Types](https://gcc.gnu.org/onlinedocs/gccint/Type-Layout.html)

### CHAR_BIT/BYTE_ORDER

- `__CHAR_BIT__`
- `__BYTE_ORDER__`
- `__BIGGEST_ALIGNMENT__`

[Numeric limits](https://en.cppreference.com/w/c/types/limits) - <limits.h\>

- `CHAR_BIT`: number of bits in a byte(macro constant)

### Data models

- `_ILP32` / `__ILP32__` ; `_LP64` / `__LP64__`
- `__SIZEOF_INT__`
- `__SIZEOF_LONG__`
- `__SIZEOF_POINTER__` / `__POINTER_WIDTH__`
- `__SIZEOF_LONG_LONG__`

The choices made by each implementation about the sizes of the fundamental types are collectively known as *data model*. Four data models found wide acceptance:

!!! note "data model of 32 bit systems"

    `LP32` or 2/4/4 (int is 16-bit, long and pointer are 32-bit)

    - Win16 API

    `ILP32` or 4/4/4 (int, long, and pointer are 32-bit);

    - Win32 API
    - Unix and Unix-like systems (Linux, macOS)

!!! note "data model of 64 bit systems"

    `LLP64` or 4/4/8 (int and long are 32-bit, pointer is 64-bit)

    - Win32 API (also called the Windows API) with compilation target 64-bit ARM (AArch64) or x86-64 (a.k.a. x64)

    `LP64` or 4/8/8 (int is 32-bit, long and pointer are 64-bit)

    - Unix and Unix-like systems (Linux, macOS)

机器的指针位数一般和机器字长相等：

- sizeof(`__INTPTR_TYPE__`) = sizeof(`__UINTPTR_TYPE__`) = `__SIZEOF_POINTER__` = `__SIZEOF_LONG__`
- `__INTPTR_WIDTH__` = `__UINTPTR_WIDTH__` = `__POINTER_WIDTH__` = `LONG_BIT` = `__WORDSIZE`

### __WORDSIZE

Xcode 中 MacOSX.sdk 下 usr/include 的 i386 和 arm 下的 limits.h 中定义了 `WORD_BIT` 和 `LONG_BIT`：

```c
$ cd `xcrun --show-sdk-path`
$ vim usr/include/i386/limits.h
$ vim usr/include/arm/limits.h

#if !defined(_ANSI_SOURCE)
#ifdef __LP64__
#define LONG_BIT	64
#else /* !__LP64__ */
#define LONG_BIT	32
#endif /* __LP64__ */
#define	SSIZE_MAX	LONG_MAX	/* max value for a ssize_t */
#define WORD_BIT	32
```

WORD_BIT 的值为 32，对应 int 类型的位宽（`__SIZEOF_INT__` * CHAR_BIT），LONG_BIT 的值则随机器 CPU 字长。

在 macOS、Linux 上可以执行 `getconf WORD_BIT` / `getconf LONG_BIT` 来 Query and retrieve system configuration variables。

Xcode 的 MacOSX.sdk 和 iPhoneOS.sdk 的 usr/include/stdint.h 根据 `__LP64__==1` 区分定义了机器字长 `__WORDSIZE`：

```c
$ cd `xcrun --show-sdk-path`
$ vim usr/include/stdint.h
#if __LP64__
#define __WORDSIZE 64
#else
#define __WORDSIZE 32
#endif
```

rpi4b-ubuntu 下没找到 `LONG_BIT`/`WORD_BIT` 的定义：

```Shell
grep -R -H "#define LONG_BIT" /usr/include 2>/dev/null
grep -R -H "#define WORD_BIT" /usr/include 2>/dev/null
```

/usr/include/aarch64-linux-gnu/bits/wordsize.h 中根据 `__LP64__` 定义与否来区分定义机器字长 `__WORDSIZE`：

- [default wordsize in UNIX/Linux](https://unix.stackexchange.com/questions/74648/default-wordsize-in-unix-linux)

```c
// Determine the wordsize from the preprocessor defines.
#ifdef __LP64__
# define __WORDSIZE         64
#else
# define __WORDSIZE         32
# define __WORDSIZE32_SIZE_ULONG    1
# define __WORDSIZE32_PTRDIFF_LONG  1
#endif
```

LONG_BIT （= `__SIZEOF_LONG__` * CHAR_BIT）的值等于机器字长（`__WORDSIZE`），为 CPU GPRs（General-Purpose Registers，通用寄存器）的数据宽度：在32位CPU下为32，在64位CPU下为64。

参考阅读：

- 《[汇编语言(4e)](https://item.jd.com/12841436.html)》王爽, 2019: 第一章 基础知识 - 地址总线、数据总线、控制总线
- 《[大话处理器](https://book.douban.com/subject/6809087/)》万木杨, 2011: 3.5　汇编语言格式——没有规矩不成方圆 | 3.5.1 机器字长

### wchar_t

- `__WCHAR_TYPE__`
- `__WCHAR_WIDTH__`
- `__SIZEOF_WCHAR_T__`

[Null-terminated wide strings](https://en.cppreference.com/w/c/string/wide)

- <wchar.h\>(since C95): Extended multibyte and wide character utilities
- <wctype.h\>(since C95): Functions to determine the type contained in wide character data
- `wchar_t` : integer type that can hold any valid wide character(typedef)


### size_t

- `__SIZE_TYPE__`
- `__SIZE_WIDTH__`
- `__SIZEOF_SIZE_T__`

[Type support](https://en.cppreference.com/w/c/types)

- `size_t`: unsigned integer type returned by the sizeof operator(typedef)

rpi4b-ubuntu 的 /usr/include/stdint.h 中定义了：

```c
# define SIZE_WIDTH __WORDSIZE
```

### intptr_t/uintptr_t

- `__INTPTR_TYPE__`, `__INTPTR_WIDTH__`
- `__UINTPTR_TYPE__`, `__UINTPTR_WIDTH__`

[Fixed width integer types (since C99)](https://en.cppreference.com/w/c/types/integer)

- `intptr_t`: integer type capable of holding a pointer
- `uintptr_t`: unsigned integer type capable of holding a pointer

rpi4b-ubuntu 的 /usr/include/stdint.h 中定义了：

```c
# define INTPTR_WIDTH __WORDSIZE
# define UINTPTR_WIDTH __WORDSIZE
```

### ptrdiff_t

- `__PTRDIFF_TYPE__`
- `__PTRDIFF_WIDTH__`

[Type support](https://en.cppreference.com/w/c/types)

- `ptrdiff_t`: signed integer type returned when subtracting two pointers(typedef)

rpi4b-ubuntu 的 /usr/include/stdint.h 中定义了：

```c
# define PTRDIFF_WIDTH __WORDSIZE
```
