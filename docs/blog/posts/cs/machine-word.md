---
title: Machine Word
authors:
  - xman
date:
    created: 2021-10-10T10:00:00
    updated: 2024-05-02T12:00:00
categories:
    - CS
tags:
    - LONG_BIT
    - WORDSIZE
comments: true
---

In computing, a ***word*** is the natural unit of data used by a particular processor design. The term `word` refers to the standard number of bits that are manipulated as a **unit** by any particular CPU.

The `word size` is the computer's *preferred* size for moving units of information around; technically it's the **width** of your processor's registers. It reflects the amount of data that can be transmitted between memory and the processor in one **chunk**. Likewise, it may reflect the size of data that can be manipulated by the CPU's ALU in one **cycle**.

<!-- more -->

## machine word

[Word (computer architecture)](https://en.wikipedia.org/wiki/Word_(computer_architecture))

In computing, a `word` is the natural unit of data used by a particular processor design. A word is a fixed-sized datum handled as a **unit** by the instruction set or the hardware of the processor. The number of bits or digits in a word (the word size, word width, or word length) is an important characteristic of any specific processor design or computer architecture.

The size of a word is reflected in many aspects of a computer's structure and operation; the majority of the registers in a processor are usually word-sized and the largest datum that can be transferred to and from the working memory in a **single** operation is a word in many (not all) architectures. The largest possible address size, used to designate a location in memory, is typically a hardware word (here, "hardware word" means the full-sized natural word of the processor, as opposed to any other definition used).

[How does my computer store things in memory?](https://tldp.org/HOWTO/Unix-and-Internet-Fundamentals-HOWTO/core-formats.html)

The `word size` is the computer's *preferred* size for moving units of information around; technically it's the **width** of your processor's registers, which are the holding areas your processor uses to do arithmetic and logical calculations. When people write about computers having bit sizes (calling them, say, "32-bit" or "64-bit" computers), this is what they mean.

The computer views your memory as a sequence of words numbered from zero up to some large value dependent on your memory size. That value is limited by your word size, which is why programs on older machines like 286s had to go through painful contortions to address large amounts of memory.

[Bits, Bytes, and Words](https://www.cs.scranton.edu/~ep/EP/data_bits.html)

The term `word` refers to the standard number of bits that are manipulated as a **unit** by any particular CPU. For decades most CPUs had a word size of 32 bits (or 4 contiguous bytes), but word sizes of 64 bits are becoming more and more commonplace. The signifcance of the word size of a particular computer system is that it reflects the amount of data that can be transmitted between memory and the processor in one **chunk**. Likewise, it may reflect the size of data that can be manipulated by the CPU's ALU in one **cycle**. Computers can process data of larger sizes, but the word size reflects the size of the data values the computer has been designed to readily process directly. All other things being equal, (and they never are), larger word size implies faster and more capable processing.

## predefined macros

GCC Internals - [Layout of Source Language Data Types](https://gcc.gnu.org/onlinedocs/gccint/Type-Layout.html)
GNU C Preprocessor - [Common Predefined Macros](https://gcc.gnu.org/onlinedocs/cpp/Common-Predefined-Macros.html)

[Clang Preprocessor options](https://clang.llvm.org/docs/ClangCommandLineReference.html#preprocessor-options) - [Dumping preprocessor state](https://clang.llvm.org/docs/ClangCommandLineReference.html#id8)

对于 GCC/Clang 预处理器定义的一些宏，可执行 `cpp -dM` /`gcc -E -dM` 预处理命令 dump Macros：

```Shell title="dump prededined macros"
$ echo | cpp -dM
$ echo | gcc -x c -E -dM -
$ echo | g++ -x c++ -E -dM -

# IA32/IA64
$ clang -x c -E -dM -arch i386 /dev/null
$ clang -x c -E -dM -arch x86_64 /dev/null

# ARM32/ARM64
$ clang -x c -E -dM -arch armv7s /dev/null
$ clang -x c -E -dM -arch arm64 /dev/null
```

### \_\_SIZEOF_POINTER\_\_

在 IA32/ARM32 位平台上，通常会定义宏 `_ILP32` 或 `__ILP32__` 值为 1；
在 IA64/ARM64 位平台上，通常会定义宏 `_LP64` 或 `__LP64__` 值为 1。

ILP32 和 LP64 是两组不同的数据模型（[Data Model](../cs/data-model.md)），决定了平台是 32 位还是 64 位，进而影响 long、long long 和 pointer 的宽度：

- `__SIZEOF_LONG__` @[intel](https://www.intel.com/content/www/us/en/developer/articles/technical/size-of-long-integer-type-on-different-architecture-and-os.html)
- `__SIZEOF_LONG_LONG__`
- `__SIZEOF_POINTER__` / `__POINTER_WIDTH__`

LP32 和 LP64，其中的 `L` 表示 long，`P` 表示 pointer，`__SIZEOF_POINTER__` 一般等于机器字长。

### WORD_BIT/LONG_BIT

[linux kernel - WORD_BIT vs LONG_BIT](https://unix.stackexchange.com/questions/771686/word-bit-vs-long-bit)

> POSIX [<limits.h\>](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/limits.h.html) defines `WORD_BIT` and `LONG_BIT` as the number of bits in objects of types `int` and `long` respectively.

cd 进入 `xcrun --show-sdk-path`，执行 grep 命令在 usr/include 头文件中查看 `WORD_BIT` 和 `LONG_BIT` 的宏定义：

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
