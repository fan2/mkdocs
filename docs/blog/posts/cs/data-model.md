---
title: Data Models
authors:
  - xman
date:
    created: 2021-10-08T10:00:00
    updated: 2024-05-10T10:00:00
categories:
    - CS
tags:
    - ILP32
    - LLP64
    - LP64
comments: true
---

In 32-bit programs, pointers and data types such as integers generally have the same length. This is not necessarily true on 64-bit machines. Mixing data types in programming languages such as C and its descendants such as C++ and Objective-C may thus work on 32-bit implementations but not on 64-bit implementations.

<!-- more -->

## Preamble

对于 GCC/Clang 预处理器定义的一些宏，在 [Dump Compiler Options](../toolchain/dump-compiler-options.md) 中有介绍如何 dump compiler predefined macros。

- GCC Internals - [Layout of Source Language Data Types](https://gcc.gnu.org/onlinedocs/gccint/Type-Layout.html)
- GNU C Preprocessor - [Common Predefined Macros](https://gcc.gnu.org/onlinedocs/cpp/Common-Predefined-Macros.html)
- [Clang Preprocessor options](https://clang.llvm.org/docs/ClangCommandLineReference.html#preprocessor-options) - [Dumping preprocessor state](https://clang.llvm.org/docs/ClangCommandLineReference.html#id8)

可执行 `cpp -dM` /`gcc -E -dM` 预处理命令 dump Macros：

```Shell title="dump prededined macros"
$ echo | cpp -dM
$ echo | gcc -x c -E -dM -
$ echo | g++ -x c++ -E -dM -

# IA32/IA64
$ llvm-gcc -x c -E -dM -arch i386 /dev/null
$ llvm-gcc -x c -E -dM -arch x86_64 /dev/null

# ARM32/ARM64
$ llvm-gcc -x c -E -dM -arch armv7s /dev/null
$ llvm-gcc -x c -E -dM -arch arm64 /dev/null
```

例如：[Numeric limits](https://en.cppreference.com/w/c/types/limits) - <limits.h\> 中定义了 `CHAR_BIT`：

- `CHAR_BIT`: number of bits in a byte(macro constant)

在 macOS 和 rpi4b-ubuntu 下执行预处理命令，grep 过滤打印出 `__CHAR_BIT__`（其值均为 8）。

```Shell
# macOS
llvm-gcc -x c -E -dM -arch i386 /dev/null | grep "__CHAR_BIT__"
llvm-gcc -x c -E -dM -arch x86_64 /dev/null | grep "__CHAR_BIT__"
llvm-gcc -x c -E -dM -arch armv7s /dev/null | grep "__CHAR_BIT__"
llvm-gcc -x c -E -dM -arch arm64 /dev/null | grep "__CHAR_BIT__"

# rpi4b-ubuntu
echo | cpp -dM | grep "__CHAR_BIT__"
gcc -x c -E -dM /dev/null | grep "__CHAR_BIT__"
```

在 IA32/ARM32 位平台上，通常会预定义宏 `_ILP32` 或 `__ILP32__` 值为 1；
在 IA64/ARM64 位平台上，通常会预定义宏 `_LP64` 或 `__LP64__` 值为 1。

`ILP32` 和 `LP64` 是两组不同的数据模型（Data Model），决定了平台是 32 位还是 64 位，进而影响 long、long long 和 pointer 的宽度。

涉及到机器字长并决定数据模型相关的宏：

- `__SIZEOF_LONG__` @[intel](https://www.intel.com/content/www/us/en/developer/articles/technical/size-of-long-integer-type-on-different-architecture-and-os.html)
- `__SIZEOF_POINTER__` / `__POINTER_WIDTH__`

4 个 [Standard Variants](../c/c-data-types.md) 相关的宏：

1. `__WCHAR_TYPE__`, `__WCHAR_WIDTH__`, `__SIZEOF_WCHAR_T__`
2. `__SIZE_TYPE__`, `__SIZE_WIDTH__`, `__SIZEOF_SIZE_T__`
3. `__INTPTR_TYPE__`, `__INTPTR_WIDTH__`; `__UINTPTR_TYPE__`, `__UINTPTR_WIDTH__`
4. `__PTRDIFF_TYPE__`, `__PTRDIFF_WIDTH__`

以下为 mbpa2991-macOS/arm64 和 rpi4b-ubuntu/aarch64 下 dump 过滤出来的相关宏。

??? info "macros varying by data model"

    ```Shell
    $ llvm-gcc -x c -E -dM -arch i386 /dev/null | grep -E "LP32|LP64|__SIZEOF_LONG__|__SIZEOF_POINTER__|__WCHAR_TYPE__|__SIZE_TYPE__|__INTPTR_TYPE__|__UINTPTR_TYPE__|__PTRDIFF_TYPE__"
    #define _ILP32 1
    #define __ILP32__ 1
    #define __INTPTR_TYPE__ long int
    #define __PTRDIFF_TYPE__ int
    #define __SIZEOF_LONG__ 4
    #define __SIZEOF_POINTER__ 4
    #define __SIZE_TYPE__ long unsigned int
    #define __UINTPTR_TYPE__ long unsigned int
    #define __WCHAR_TYPE__ int

    $ llvm-gcc -x c -E -dM -arch x86_64 /dev/null | grep -E "LP32|LP64|__SIZEOF_LONG__|__SIZEOF_POINTER__|__WCHAR_TYPE__|__SIZE_TYPE__|__INTPTR_TYPE__|__UINTPTR_TYPE__|__PTRDIFF_TYPE__"
    #define _LP64 1
    #define __INTPTR_TYPE__ long int
    #define __LP64__ 1
    #define __PTRDIFF_TYPE__ long int
    #define __SIZEOF_LONG__ 8
    #define __SIZEOF_POINTER__ 8
    #define __SIZE_TYPE__ long unsigned int
    #define __UINTPTR_TYPE__ long unsigned int
    #define __WCHAR_TYPE__ int

    $ llvm-gcc -x c -E -dM -arch armv7s /dev/null | grep -E "LP32|LP64|__SIZEOF_LONG__|__SIZEOF_POINTER__|__WCHAR_TYPE__|__SIZE_TYPE__|__INTPTR_TYPE__|__UINTPTR_TYPE__|__PTRDIFF_TYPE__"
    #define _ILP32 1
    #define __ILP32__ 1
    #define __INTPTR_TYPE__ long int
    #define __PTRDIFF_TYPE__ int
    #define __SIZEOF_LONG__ 4
    #define __SIZEOF_POINTER__ 4
    #define __SIZE_TYPE__ long unsigned int
    #define __UINTPTR_TYPE__ long unsigned int
    #define __WCHAR_TYPE__ int

    $ llvm-gcc -x c -E -dM -arch arm64 /dev/null | grep -E "LP32|LP64|__SIZEOF_LONG__|__SIZEOF_POINTER__|__WCHAR_TYPE__|__SIZE_TYPE__|__INTPTR_TYPE__|__UINTPTR_TYPE__|__PTRDIFF_TYPE__"
    #define _LP64 1
    #define __INTPTR_TYPE__ long int
    #define __LP64__ 1
    #define __PTRDIFF_TYPE__ long int
    #define __SIZEOF_LONG__ 8
    #define __SIZEOF_POINTER__ 8
    #define __SIZE_TYPE__ long unsigned int
    #define __UINTPTR_TYPE__ long unsigned int
    #define __WCHAR_TYPE__ int

    # rpi4b-ubuntu/aarch64
    $ gcc -x c -E -dM /dev/null | grep -E "LP32|LP64|__SIZEOF_LONG__|__SIZEOF_POINTER__|__WCHAR_TYPE__|__SIZE_TYPE__|__INTPTR_TYPE__|__UINTPTR_TYPE__|__PTRDIFF_TYPE__"
    #define __SIZEOF_LONG__ 8
    #define __SIZEOF_POINTER__ 8
    #define __LP64__ 1
    #define __SIZE_TYPE__ long unsigned int
    #define __INTPTR_TYPE__ long int
    #define __WCHAR_TYPE__ unsigned int
    #define _LP64 1
    #define __PTRDIFF_TYPE__ long int
    #define __UINTPTR_TYPE__ long unsigned int
    ```

## Concept

[64-bit data models](https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models)

In many programming environments for C and C-derived languages on 64-bit machines, `int` variables are still 32 bits wide, but `long` integers and `pointers` are 64 bits wide. These are described as having an ***LP64*** data model, which is an abbreviation of "Long, Pointer, 64". Other models are the ***ILP64*** data model in which all three data types are 64 bits wide, and even the ***SILP64*** model where short integers are also 64 bits wide. However, in most cases the modifications required are relatively minor and straightforward, and many well-written programs can simply be recompiled for the new environment with no changes. Another alternative is the ***LLP64*** model, which maintains compatibility with 32-bit code by leaving both `int` and `long` as 32-bit. `LL` refers to the `long long` integer type, which is at least 64 bits on all platforms, including 32-bit environments.

There are also systems with 64-bit processors using an ***ILP32*** data model, with the addition of 64-bit `long long` integers; this is also used on many platforms with 32-bit processors. This model reduces code size and the size of data structures containing pointers, at the cost of a much smaller address space, a good choice for some embedded systems.

GCC Internals | Effective-Target Keywords | [Data type sizes](https://gcc.gnu.org/onlinedocs/gccint/Effective-Target-Keywords.html#Data-type-sizes)

- `ilp32`: Target has 32-bit int, long, and pointers.
- `lp64`: Target has 32-bit int, 64-bit long and pointers.
- `llp64`: Target has 32-bit int and long, 64-bit long long and pointers.

[aapcs64](https://github.com/ARM-software/abi-aa/blob/2a70c42d62e9c3eb5887fa50b71257f20daca6f9/aapcs64/aapcs64.rst) - 2.2 Terms and abbreviations:

- `ILP32`: SysV-like data model where int, long int and pointer are 32-bit.
- `LP64`: SysV-like data model where int is 32-bit, but long int and pointer are 64-bit.
- `LLP64`: Windows-like data model where int and long int are 32-bit, but long long int and pointer are 64-bit.

[Fundamental types](https://en.cppreference.com/w/cpp/language/types) - Data Models:

The choices made by each *implementation* about the sizes of the fundamental types are collectively known as *data model*. Four data models found wide acceptance:

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

> refer to the table corresponding to the width in bits by data model.


## Convention

ARM/Keil : [Basic data types in ARM C and C++](https://developer.arm.com/documentation/dui0375/g/C-and-C---Implementation-Details/Basic-data-types-in-ARM-C-and-C--)

- Size and alignment of basic data types

AIX - [Data models for 32-bit and 64-bit processes](https://www.ibm.com/docs/en/aix/7.3?topic=assignment-data-models-32-bit-64-bit-processes)
z/OS - [LP64 | ILP32](https://www.ibm.com/docs/en/zos/3.1.0?topic=options-lp64-ilp32), [ILP32 and LP64 data models and data type sizes](https://www.ibm.com/docs/en/ent-metalc-zos/3.1?topic=environments-ilp32-lp64-data-models-data-type-sizes)

- `ILP32`, acronym for integer, long, and pointer 32
- `LP64`, acronym for long, and pointer 64

[ILP32 and LP64 data models.PDF](https://scc.ustc.edu.cn/zlsc/czxt/200910/W020100308601263456982.pdf) - HP-UX 64-bit data model

- hp C/HP-UX 32-bit and 64-bit base data types
- ILP32 and LP64 data alignment

[Writing 64-bit Intel code for Apple Platforms](https://developer.apple.com/documentation/xcode/writing-64-bit-intel-code-for-apple-platforms)

> Apple platforms typically follow the data representation and procedure call rules in the standard System V psABI for AMD64, using the **LP64** programming model.

[Programming Guide for 64-bit Windows](https://learn.microsoft.com/en-us/windows/win32/winprog64/programming-guide-for-64-bit-windows)
[Getting Ready for 64-bit Windows](https://learn.microsoft.com/en-us/windows/win32/winprog64/getting-ready-for-64-bit-windows)

- [Abstract Data Models](https://learn.microsoft.com/en-us/windows/win32/winprog64/abstract-data-models)
- [The New Data Types](https://learn.microsoft.com/en-us/windows/win32/winprog64/the-new-data-types)

> In the 32-bit programming model (known as the **ILP32** model), integer, long, and pointer data types are 32 bits in length.
> In the **LLP64** data model, only pointers expand to 64 bits; all other basic data types (integer and long) remain 32 bits in length.

GCC [IA-64 Options](https://gcc.gnu.org/onlinedocs/gcc/IA-64-Options.html)

```Shell
-milp32 / -mlp64
Generate code for a 32-bit or 64-bit environment. The 32-bit environment sets int, long and pointer to 32 bits. The 64-bit environment sets int to 32 bits and long and pointer to 64 bits. These are HP-UX specific flags.
```

[数据模型](https://blog.csdn.net/wyywatdl/article/details/4683762)，[資料模型](https://ryan0988.pixnet.net/blog/post/194111613)，[64-bit data models](https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models)

TYPE      | LP32 | ILP32 | LP64 | ILP64 | LLP64
----------|:----:|:-----:|:----:|:-----:|:-----:
CHAR      | 8    | 8     | 8    | 8     | 8
SHORT     | 16   | 16    | 16   | 16    | 16
INT       | 16   | 32    | 32   | 64    | 32
LONG      | 32   | 32    | 64   | 64    | 32
LONG LONG | 64   | 64    | 64   | 64    | 64
POINTER   | 32   | 32    | 64   | 64    | 64 

- `LP32`: sizeof(long)=sizeof(pointer)=32
- `ILP32`: sizeof(int)=sizeof(long)=sizeof(pointer)=32

- `LP64`: sizeof(long)=sizeof(pointer)=64
- `LLP64`: sizeof(long long)=sizeof(pointer)=64
- `ILP64`: sizeof(int)=sizeof(long)=sizeof(pointer)=64

    - `ILP64` model is very rare, only appeared in some early 64-bit Unix systems (e.g. UNICOS on Cray).

[aapcs64](https://github.com/ARM-software/abi-aa/blob/2a70c42d62e9c3eb5887fa50b71257f20daca6f9/aapcs64/aapcs64.rst) - 7 The standard variants:

10.1.2 Types varying by data model:

C/C++ Type | ILP32 (Beta) | LP64 | LLP64
-----------|--------------|------|------
[signed] long | signed word | signed double-word | signed word
unsigned long | unsigned word | unsigned double-word | unsigned word
wchar_t | unsigned word | unsigned word | unsigned halfword
T * | 32-bit data pointer | 64-bit data pointer | 64-bit data pointer

10.1.4 Additional types:

Typedef | ILP32 (Beta) | LP64 | LLP64
--------|--------------|------|------
size_t | unsigned long | unsigned long | unsigned long long
ptrdiff_t | signed long | signed long | signed long long

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) - 5.1 The ARMv8 instruction sets - 5.1.3 Registers - Table 5-1 Variable width

| Type      | ILP32 | LP64 | LLP64 |
| --------- | :---: | :--: | :---: |
| char      | 8     | 8    | 8     |
| short     | 16    | 16   | 16    |
| int       | 32    | 32   | 32    |
| long      | 32    | 64   | 32    |
| long long | 64    | 64   | 64    |
| size\_t   | 32    | 64   | 64    |
| pointer   | 32    | 64   | 64    |

在 LP 数据模型下：

- `__SIZEOF_POINTER__` = `__SIZEOF_LONG__`
- `__POINTER_WIDTH__` = `LONG_BIT` = `__WORDSIZE`

关于机器字长相关的宏 `LONG_BIT` 和 `__WORDSIZE`，参考 《[Machine Word](./machine-word.md)》。

## Evolution

[The Evolution of Computing: From 8-bit to 64-bit](https://www.deusinmachina.net/p/the-evolution-of-computing-from-8)
[The Evolution of CPUs: Exploring the Dominance of 32-bit and 64-bit Architectures](https://www.linkedin.com/pulse/evolution-cpus-exploring-dominance-32-bit-64-bit-devendar-pasula/)
[The 64-bit Evolution – Computerworld](https://www.computerworld.com/article/1692048/the-64-bit-evolution.html)

[The Long Road to 64 Bits](https://queue.acm.org/detail.cfm?id=1165766) - [PDF](https://dl.acm.org/doi/pdf/10.1145/1435417.1435431) - TABLE 1 Common C Data Types

[Data Models and Word Size](http://nickdesaulniers.github.io/blog/2016/05/30/data-models-and-word-size/)

[64-bit and Data Size Neutrality](https://unix.org/whitepapers/64bit.html)

---

opengroup - [64-Bit Programming Models: Why LP64?.PDF](https://wiki.math.ntnu.no/_media/tma4280/2017v/1997_opengroup_64bitprogrammingmodels.pdf) - 1997

[Major 64-Bit Changes - Apple Developer](https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/64bitPorting/transition/transition.html) - 20121213

[Why did the Win64 team choose the LLP64 model?](https://devblogs.microsoft.com/oldnewthing/20050131-00/?p=36563)
[What is the bit size of long on 64-bit Windows?](https://stackoverflow.com/questions/384502/what-is-the-bit-size-of-long-on-64-bit-windows)

> All modern 64-bit Unix systems use **LP64**. MacOS X and Linux are both modern 64-bit systems.  
> Microsoft uses a different scheme for transitioning to 64-bit: **LLP64** ('long long, pointers are 64-bit').   
> This has the merit of meaning that 32-bit software can be recompiled without change.  

[The Tools](https://learn.microsoft.com/en-us/windows/win32/winprog64/the-tools) - 64-bit Compiler Switches and Warnings

[Wireshark Development/Win64](https://wiki.wireshark.org/Development/Win64)  

> 32-bit UNX platforms, and 32-bit Windows, use the **ILP32** data model.  
> 64-bit UNX platform use the **LP64** data model; however, 64-bit Windows uses the **LLP64** data model.  
