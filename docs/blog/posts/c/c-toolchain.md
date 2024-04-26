---
draft: true
title: C Programming Language Toolchain
authors:
  - xman
date:
    created: 2009-10-02T10:00:00
categories:
    - c
comments: true
---

C Programming Language Standard from ANSI C to ISO C and standard library.

<!-- more -->

## GNU/GCC

[The GNU Operating System and the Free Software Movement](https://www.gnu.org/)

!!! abstract "What is GNU?"

    GNU is an operating system that is [free software](https://www.gnu.org/philosophy/free-sw.html)—that is, it respects users' freedom. The GNU operating system consists of GNU packages (programs specifically released by the GNU Project) as well as free software released by third parties. The development of GNU made it possible to use a computer without software that would trample your freedom.

    We recommend installable versions of GNU (more precisely, [GNU/Linux](https://www.gnu.org/gnu/linux-and-gnu.html) distributions) which are entirely free software.

[GCC, the GNU Compiler Collection](https://gcc.gnu.org/)

!!! abstract "What is GCC?"

    The GNU Compiler Collection includes front ends for [](https://gcc.gnu.org/c99status.html), [C++](https://gcc.gnu.org/projects/cxx-status.html), Objective-C, Fortran, Ada, Go, and D, as well as libraries for these languages (libstdc++,...). GCC was originally written as the compiler for the [GNU operating system](http://www.gnu.org/gnu/thegnuproject.html). The GNU system was developed to be 100% free software, free in the sense that it respects the user's freedom.

    We strive to provide regular, high quality [releases](https://gcc.gnu.org/releases.html), which we want to work well on a variety of native and cross targets (including GNU/Linux), and encourage everyone to contribute changes or help testing GCC.

[GCC online documentation](https://gcc.gnu.org/onlinedocs/)

### Language Standards

[Language Standards Supported by GCC](https://gcc.gnu.org/onlinedocs/gcc/Standards.html)

- [Options Controlling C Dialect](https://gcc.gnu.org/onlinedocs/gcc/C-Dialect-Options.html)
- [Options Controlling C++ Dialect](https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Dialect-Options.html)

### libc vs. glibc

[The GNU C Library - GNU Project](https://www.gnu.org/software/libc/)

- [Index of /gnu/libc](https://ftp.gnu.org/gnu/libc/)
- [Documentation for the GNU C Library](https://sourceware.org/glibc/manual/)

[c - What is the role of libc(glibc) in our linux app?](https://stackoverflow.com/questions/11372872/what-is-the-role-of-libcglibc-in-our-linux-app)
[libc、glibc和glib的关系_libc和glibc-CSDN博客](https://blog.csdn.net/yasi_xi/article/details/9899599)
[libc、glib、glibc简介 - 阿C - 博客园](https://www.cnblogs.com/arci/p/14591030.html)
[【Linux】理清gcc、glibc、libc++/libstdc++的关系 - 简书](https://www.jianshu.com/p/a3c983edabd1)

glibc 和 libc 都是 Linux 下的 C 函数库：

1. libc 是 Linux 下的 ANSI C 函数库；
2. glibc 是 Linux 下的 GUN C 函数库。

glibc（即 GNU C Library）本身是GNU旗下的C标准库，后来逐渐成为了Linux的标准C库，而Linux下原来的标准C库libc逐渐不再被维护。

## stdc version

[What is the default C -std standard version for the current GCC (especially on Ubuntu)? - Stack Overflow](https://stackoverflow.com/questions/14737104/what-is-the-default-c-std-standard-version-for-the-current-gcc-especially-on-u)

```Shell title="__STDC_VERSION__"
# ubuntu
$ gcc -dM -E -x c /dev/null | grep -F __STDC_VERSION__
#define __STDC_VERSION__ 201710L

# macOS clang/gcc
$ gcc -dM -E -x c /dev/null | grep -F __STDC_VERSION__
#define __STDC_VERSION__ 201710L
```

If you feel like finding it out empirically without reading any manuals.

```c title="stdc.c"
#include <stdio.h>

int main(void) {
#ifdef __STDC_VERSION__
    printf("__STDC_VERSION__ = %ld \n", __STDC_VERSION__);
#endif
#ifdef __STRICT_ANSI__
    puts("__STRICT_ANSI__");
#endif
    return 0;
}
```

Test with:

```Shell
#!/usr/bin/env bash
for std in c89 c99 c11 c17 gnu89 gnu99 gnu11 gnu17; do
  echo $std
  gcc -std=$std -o c.out stdc.c
  ./c.out
  echo
done
echo default
gcc -o c.out stdc.c
./c.out
```
