---
title: C Data Types
authors:
  - xman
date:
    created: 2009-10-03T12:00:00
    updated: 2024-04-24T10:00:00
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

C language Basic Concepts - [Type](https://en.cppreference.com/w/c/language/type)

- Type classification
- Compatible types
- Composite types
- Incomplete types
- Type names

Type groups

*   *object types*: all types that aren't function types
*   *character types*: char, signed char, unsigned char
*   *integer types*: char, signed integer types, unsigned integer types, enumerated types
*   *real types*: integer types and real floating types
*   [arithmetic types](https://en.cppreference.com/w/c/language/arithmetic_types "c/language/arithmetic types"): integer types and floating types
*   *scalar types*: arithmetic types, pointer types, and [nullptr\_t](https://en.cppreference.com/w/c/types/nullptr_t "c/types/nullptr t")(since C23)
*   *aggregate types*: array types and structure types
*   *derived declarator types*: array types, function types, and pointer types

Constructing a complete object type such that the number of bytes in its object representation is not representable in the type [size\_t](https://en.cppreference.com/w/c/types/size_t "c/types/size t") (i.e. the result type of [`sizeof`](https://en.cppreference.com/w/c/language/sizeof "c/language/sizeof") operator), including forming such a VLA type at runtime,(since C99) is undefined behavior.

[Type support](https://en.cppreference.com/w/c/types)

- Additional basic types and convenience macros: [<stddef.h\>](https://en.cppreference.com/w/c/types)
- [Fixed width integer types (since C99)](https://en.cppreference.com/w/c/types/integer)

    - Types & Macro constants: <stdint.h\>
    - Format macro constants: <inttypes.h\>

- [Numeric limits](https://en.cppreference.com/w/c/types/limits): <limits.h\>, [<stdint.h\>](https://en.cppreference.com/w/c/types/integer)

    - [Data Type Ranges | Microsoft Learn](https://learn.microsoft.com/en-us/cpp/cpp/data-type-ranges?view=msvc-170)
    - GNU [A.5 Data Type Measurements](http://www.gnu.org/software/libc/manual/html_node/Data-Type-Measurements.html#Data-Type-Measurements) : [Width of an Integer Type](https://www.gnu.org/software/libc/manual/html_node/Width-of-Type.html) & [Range of an Integer Type](https://www.gnu.org/software/libc/manual/html_node/Range-of-Type.html)

The following table summarizes all available integer types and their [properties](https://en.cppreference.com/w/c/language/arithmetic_types):

![stdint-properties](./images/stdint-properties.png)

## printf format specifier

[C data types](https://en.wikipedia.org/wiki/C_data_types#stddef.h) - Main types - Format specifier

[printf(3) - Linux manual page](https://man7.org/linux/man-pages/man3/printf.3.html) @[opengroup](https://pubs.opengroup.org/onlinepubs/9699919799/functions/fprintf.html#)

- Flag characters
- Field width
- Precision
- Length modifier
- Conversion specifiers

printf: [cppreference.com](https://en.cppreference.com/w/c/io/fprintf), [cplusplus.com](https://cplusplus.com/reference/cstdio/printf/)

![printf-format-specifier](./images/printf-format-specifier.png)

[Fixed width integer types (since C99)](https://en.cppreference.com/w/c/types/integer)

- Format macro constants - Defined in header <inttypes.h\>
- Format constants for the fprintf family of functions
- Each of the `PRI` macros listed here is defined if and only if the implementation defines the corresponding typedef name.
- 预处理 dump 相关格式宏：`echo "#include <inttypes.h>" | cpp -dM | grep 'FMT\|PRI'`。

[fmtlib/fmt: A modern formatting library](https://github.com/fmtlib/fmt)
[Comparison of C++ Format and C library's printf](https://vitaut.net/posts/2015/comparison-of-cppformat-and-printf/)

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
- `__SIZEOF_LONG__` @[intel](https://www.intel.com/content/www/us/en/developer/articles/technical/size-of-long-integer-type-on-different-architecture-and-os.html)
- `__SIZEOF_POINTER__` / `__POINTER_WIDTH__`
- `__SIZEOF_LONG_LONG__`

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

#### convention

AIX - [Data models for 32-bit and 64-bit processes](https://www.ibm.com/docs/en/aix/7.3?topic=assignment-data-models-32-bit-64-bit-processes)
ZOS - [ILP32 and LP64 data models and data type sizes](https://www.ibm.com/docs/en/ent-metalc-zos/3.1?topic=environments-ilp32-lp64-data-models-data-type-sizes)

- `ILP32`, acronym for integer, long, and pointer 32
- `LP64`, acronym for long, and pointer 64

Data Model：[数据模型](https://blog.csdn.net/wyywatdl/article/details/4683762)，[資料模型](https://ryan0988.pixnet.net/blog/post/194111613)

TYPE      | LP32 | ILP32 | LP64 | ILP64 | LLP64
----------|------|-------|------|-------|------
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

[ILP32 and LP64 data models.PDF](https://scc.ustc.edu.cn/zlsc/czxt/200910/W020100308601263456982.pdf) - HP-UX 64-bit data model

- hp C/HP-UX 32-bit and 64-bit base data types
- ILP32 and LP64 data alignment

ARM/Keil : [Basic data types in ARM C and C++](https://developer.arm.com/documentation/dui0375/g/C-and-C---Implementation-Details/Basic-data-types-in-ARM-C-and-C--)

- Size and alignment of basic data types

[IA-64 Options](https://gcc.gnu.org/onlinedocs/gcc/IA-64-Options.html)

```Shell
-milp32 / -mlp64
Generate code for a 32-bit or 64-bit environment. The 32-bit environment sets int, long and pointer to 32 bits. The 64-bit environment sets int to 32 bits and long and pointer to 64 bits. These are HP-UX specific flags.
```

在 LP 数据模型下：

- `__SIZEOF_POINTER__` = `__SIZEOF_LONG__`
- `LONG_BIT` = `__WORDSIZE`

#### The 64-bit Evolution

[The Evolution of Computing: From 8-bit to 64-bit](https://www.deusinmachina.net/p/the-evolution-of-computing-from-8)
[The Evolution of CPUs: Exploring the Dominance of 32-bit and 64-bit Architectures](https://www.linkedin.com/pulse/evolution-cpus-exploring-dominance-32-bit-64-bit-devendar-pasula/)
[The 64-bit Evolution – Computerworld](https://www.computerworld.com/article/1692048/the-64-bit-evolution.html)

[The Long Road to 64 Bits](https://queue.acm.org/detail.cfm?id=1165766) - [PDF](https://dl.acm.org/doi/pdf/10.1145/1435417.1435431) - TABLE 1 Common C Data Types

[Data Models and Word Size](http://nickdesaulniers.github.io/blog/2016/05/30/data-models-and-word-size/)

[64-bit and Data Size Neutrality](https://unix.org/whitepapers/64bit.html)

#### Platform Adaptation

opengroup - [64-Bit Programming Models: Why LP64?.PDF](https://wiki.math.ntnu.no/_media/tma4280/2017v/1997_opengroup_64bitprogrammingmodels.pdf) - 1997

[Major 64-Bit Changes - Apple Developer](https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/64bitPorting/transition/transition.html) - 20121213

[Why did the Win64 team choose the LLP64 model?](https://devblogs.microsoft.com/oldnewthing/20050131-00/?p=36563)
[What is the bit size of long on 64-bit Windows?](https://stackoverflow.com/questions/384502/what-is-the-bit-size-of-long-on-64-bit-windows)

> All modern 64-bit Unix systems use **LP64**. MacOS X and Linux are both modern 64-bit systems.  
> Microsoft uses a different scheme for transitioning to 64-bit: **LLP64** ('long long, pointers are 64-bit').   
> This has the merit of meaning that 32-bit software can be recompiled without change.  

[Programming Guide for 64-bit Windows](https://learn.microsoft.com/en-us/windows/win32/winprog64/programming-guide-for-64-bit-windows)
[Getting Ready for 64-bit Windows](https://learn.microsoft.com/en-us/windows/win32/winprog64/getting-ready-for-64-bit-windows)

- [Abstract Data Models](https://learn.microsoft.com/en-us/windows/win32/winprog64/abstract-data-models)
- [The New Data Types](https://learn.microsoft.com/en-us/windows/win32/winprog64/the-new-data-types)

> In the 32-bit programming model (known as the **ILP32** model), integer, long, and pointer data types are 32 bits in length.
> In the **LLP64** data model, only pointers expand to 64 bits; all other basic data types (integer and long) remain 32 bits in length.

[Wireshark Development/Win64](https://wiki.wireshark.org/Development/Win64)  

> 32-bit UNX platforms, and 32-bit Windows, use the **ILP32** data model.  
> 64-bit UNX platform use the **LP64** data model; however, 64-bit Windows uses the **LLP64** data model.  

### WORD_BIT/LONG_BIT

[linux kernel - WORD_BIT vs LONG_BIT](https://unix.stackexchange.com/questions/771686/word-bit-vs-long-bit)

> POSIX [<limits.h\>](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/limits.h.html) defines `WORD_BIT` and `LONG_BIT` as the number of bits in objects of types `int` and `long` respectively.

cd 进入 `xcrun --show-sdk-path`，执行 grep 命令在 usr/include 头文件中查看 WORD_BIT 和 LONG_BIT 的宏定义：

```Shell
cd `xcrun --show-sdk-path`
# grep -RFl "#define WORD_BIT" usr/include 2>/dev/null
# grep -RFl "#define LONG_BIT" usr/include 2>/dev/null

# --dereference-recursive, --extended-regexp, --files-with-matches
$ grep -REl "#define (WORD_BIT|LONG_BIT)" usr/include 2>/dev/null
usr/include/i386/limits.h
usr/include/arm/limits.h
```

i386 和 arm 下的头文件 limits.h 中定义了 `WORD_BIT` 和 `LONG_BIT`：

```c title="limits.h"
$ cd `xcrun --show-sdk-path`

#if !defined(_ANSI_SOURCE)
#ifdef __LP64__
#define LONG_BIT	64
#else /* !__LP64__ */
#define LONG_BIT	32
#endif /* __LP64__ */
#define	SSIZE_MAX	LONG_MAX	/* max value for a ssize_t */
#define WORD_BIT	32
```

WORD_BIT 的值为 32，对应 int 类型的位宽（`__SIZEOF_INT__` * CHAR_BIT），LONG_BIT 的值则跟随 Data Model。

在 rpi4b-ubuntu 下，grep 搜索 /usr/include 目录，没找到 `WORD_BIT`/`LONG_BIT` 的定义。

- [Why is there no WORD_BIT in limits.h on Linux?](https://unix.stackexchange.com/questions/715751/why-is-there-no-word-bit-in-limits-h-on-linux)

在 macOS、Linux 上可以执行 `getconf WORD_BIT` / `getconf LONG_BIT` 查询获取系统配置的变量。

- `getconf` : to tell what architecture your CPU is presenting to the OS.
- `getconf LONG_BIT` : check if the OS (kernel) is 32 bit or 64 bit.

### __WORDSIZE

机器字长表示处理器一次处理数据的长度，主要由运算器、寄存器决定，如32位处理器，每个寄存器能存储32bit数据，加法器支持两个32bit数进行相加。

!!! abstract "What is word and word size?"

    [Word (computer architecture)](https://en.wikipedia.org/wiki/Word_(computer_architecture))

    In computing, a word is the *natural* unit of data used by a particular processor design. A word is a fixed-sized datum handled as a ***unit*** by the instruction set or the hardware of the processor. The number of bits or digits in a word (the word size, word width, or word length) is an important characteristic of any specific processor design or computer architecture.

    The size of a word is reflected in many aspects of a computer's structure and operation; the majority of the registers in a processor are usually word-sized and the largest datum that can be transferred to and from the working memory in a *single* operation is a word in many (not all) architectures. The largest possible address size, used to designate a location in memory, is typically a hardware word (here, "hardware word" means the full-sized natural word of the processor, as opposed to any other definition used).

在 macOS 上执行 `sysctl hw`，在 rpi4b-ubuntu 上执行 `lscpu` 查看硬件（CPU）信息：

=== "mbpa1398-x86_64"

    ```Shell
    $ arch
    i386

    # --kernel-name, --kernel-release, --processor, --machine
    $ uname -srpm
    Darwin 20.6.0 x86_64 i386

    $ getconf LONG_BIT
    64

    # sysctl -a | grep cpu
    $ sysctl hw

    hw.optional.x86_64: 1

    hw.cpu64bit_capable: 1

    hw.cpusubtype: 8
    hw.cputype: 7
    ```

=== "mbpa2991-arm64"

    ```Shell
    $ arch
    arm64

    # --operating-system, --kernel-name, --kernel-release, --machine, --processor
    $ uname -osrmp
    Darwin 23.5.0 arm64 arm

    $ getconf LONG_BIT
    64

    # sysctl -a | grep cpu
    $ sysctl hw

    hw.optional.arm64: 1

    hw.cpu64bit_capable: 1

    hw.cputype: 16777228
    hw.cpusubtype: 2
    ```

=== "rpi4b-ubuntu - aarch64"

    ```Shell
    $ arch
    aarch64

    # --operating-system, --kernel-release, --machine, --processor, --kernel-name
    $ uname -srmpo
    Linux 5.15.0-1053-raspi aarch64 aarch64 GNU/Linux

    $ getconf LONG_BIT
    64

    # The width argument tells whether the Linux is 32- or 64-bit.
    $ lshw | head -n 10
    WARNING: you should run this program as super-user.
    rpi4b-ubuntu
        description: Computer
        product: Raspberry Pi 4 Model B Rev 1.4
        serial: 10000000a744c93f
        width: 64 bits
        capabilities: smp cp15_barrier setend swp tagged_addr_disabled
      *-core
           description: Motherboard
           physical id: 0
         *-cpu:0

    $ lscpu | head -n 8
    Architecture:                       aarch64
    CPU op-mode(s):                     32-bit, 64-bit
    Byte Order:                         Little Endian
    CPU(s):                             4
    On-line CPU(s) list:                0-3
    Vendor ID:                          ARM
    Model name:                         Cortex-A72
    Model:                              3
    ```

!!! note "lscpu CPU op-mode(s)"

    [32-bit, 64-bit CPU op-mode on Linux](https://unix.stackexchange.com/questions/77718/32-bit-64-bit-cpu-op-mode-on-linux)

    If your kernel is a 32 bit linux kernel, you won't be able to run 64 bit programs, even if your processor supports it. Install a 64 bit kernel (and whole OS of course) to run 64 bit.

    [How to determine whether a given Linux is 32 bit or 64 bit?](https://www.geeksforgeeks.org/how-to-determine-whether-a-given-linux-is-32-bit-or-64-bit/)

    The `CPU op-mode(s)` option in the command output tells whether the given Linux is 32 or 64 bits.

    If it shows 32-bit or 64-bit then Linux is 64 bits as it supports *both* 32- and 64-bit memory. If it shows only 32-bit then, then Linux is 32-bit.

    The above Linux system is clearly 64 bits.

[default wordsize in UNIX/Linux](https://unix.stackexchange.com/questions/74648/default-wordsize-in-unix-linux)

> In general wordsize is decided upon target architecture when compiling. Your compiler will normally compile using wordsize for current system.
> Using gcc (among others), on a 64-bit host you can compile for 32-bit machine, or force 32-bit words.

Xcode 的 MacOSX.sdk 和 iPhoneOS.sdk 的 usr/include/stdint.h 根据 Data Model 是否为 `__LP64__==1` 区分定义了 `__WORDSIZE`：

```c title="stdint.h"
$ cd `xcrun --show-sdk-path`
$ grep -Rl "#*define __WORDSIZE" usr/include 2>/dev/null
usr/include/stdint.h

$ vim usr/include/stdint.h
#if __LP64__
#define __WORDSIZE 64
#else
#define __WORDSIZE 32
#endif
```

在 rpi4b-ubuntu 下的 /usr/include 中查找宏 `__WORDSIZE` 定义所在的头文件：

```Shell
$ grep -Rl "#*define __WORDSIZE" /usr/include 2>/dev/null
/usr/include/aarch64-linux-gnu/bits/wordsize.h
```

wordsize.h 中根据 Data Model（`__LP64__` 定义与否）来区分定义 `__WORDSIZE`。

```c title="wordsize.h"
// Determine the wordsize from the preprocessor defines.
#ifdef __LP64__
# define __WORDSIZE         64
#else
# define __WORDSIZE         32
# define __WORDSIZE32_SIZE_ULONG    1
# define __WORDSIZE32_PTRDIFF_LONG  1
#endif
```

[ARM Compiler v5.06 for uVision armcc User Guide](https://developer.arm.com/documentation/dui0375/g/C-and-C---Implementation-Details/Basic-data-types-in-ARM-C-and-C--) ｜ Basic data types in ARM C and C++
 - Size and alignment of basic data types 的 ILP32 数据模型下 All pointers、int、long 都是 4 (word-aligned)，这里的 4 即为 __WORDSIZE/CHAR_BIT。

参考阅读：

- 《[汇编语言(4e)](https://item.jd.com/12841436.html)》王爽, 2019: 第一章 基础知识 - 地址总线、数据总线、控制总线
- 《[大话处理器](https://book.douban.com/subject/6809087/)》万木杨, 2011: 3.5　汇编语言格式——没有规矩不成方圆 | 3.5.1 机器字长
- [Machine word & x86's WORD](../cs/machine-word.md)


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

[Type support](https://en.cppreference.com/w/c/types) - <stddef.h\>

- `size_t`: unsigned integer type returned by the sizeof operator(typedef)

rpi4b-ubuntu 的 /usr/include/stdint.h 中定义了：

```c
# define SIZE_WIDTH __WORDSIZE
```

### intptr_t/uintptr_t

- `__INTPTR_TYPE__`, `__INTPTR_WIDTH__`
- `__UINTPTR_TYPE__`, `__UINTPTR_WIDTH__`

[Fixed width integer types (since C99)](https://en.cppreference.com/w/c/types/integer) - <stdint.h\>

- `intptr_t`: integer type capable of holding a pointer
- `uintptr_t`: unsigned integer type capable of holding a pointer

指针位数一般和 __WORDSIZE 相等：

- sizeof(`__INTPTR_TYPE__`) = sizeof(`__UINTPTR_TYPE__`) = `__SIZEOF_POINTER__`
- `__INTPTR_WIDTH__` = `__UINTPTR_WIDTH__` = `__POINTER_WIDTH__` = `__WORDSIZE`

rpi4b-ubuntu 的 /usr/include/stdint.h 中定义了：

```c
# define INTPTR_WIDTH __WORDSIZE
# define UINTPTR_WIDTH __WORDSIZE
```

### ptrdiff_t

- `__PTRDIFF_TYPE__`
- `__PTRDIFF_WIDTH__`

[Type support](https://en.cppreference.com/w/c/types) - <stddef.h\>

- `ptrdiff_t`: signed integer type returned when subtracting two pointers(typedef)

rpi4b-ubuntu 的 /usr/include/stdint.h 中定义了：

```c
# define PTRDIFF_WIDTH __WORDSIZE
```