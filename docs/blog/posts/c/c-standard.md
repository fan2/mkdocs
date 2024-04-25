---
title: C Programming Language Standard
authors:
  - xman
date:
    created: 2009-10-01T10:00:00
categories:
    - c
comments: true
---

C Programming Language Standard from ANSI C to ISO C and standard library.

<!-- more -->

## C

[C (programming language)](https://en.wikipedia.org/wiki/C_%28programming_language)

## ANSI C

[ANSI C](https://en.wikipedia.org/wiki/ANSI_C)

- [The Origin of ANSI C and ISO C - ANSI Blog](https://blog.ansi.org/2017/09/origin-ansi-c-iso-c/)
- [C Programming ANSI Keywords - Developer Help](https://developerhelp.microchip.com/xwiki/bin/view/software-tools/c-programming/variables/ansi-keywords/)

The_C_Programming_Language(2e)-1988 Preface:

The computing world has undergone a revolution since the publication of *The C Programming Language* in 1978. Big computers are much bigger, and personal computers have capabilities that rival mainframes of a decade ago. During this time, C has changed too, although only modestly, and it has spread far beyond its origins as the language of the UNIX operating system.

The growing popularity of C, the changes in the language over the years, and the creation of compilers by groups not involved in its design, combined to demonstrate a need for a more precise and more contemporary definition of the language than the first edition of this book provided. In 1983, the American National Standards Institute (**ANSI**) established a committee whose goal was to produce an ==unambiguous== and ==machine-independent== definition of the language C, while still retaining its spirit. The result is the `ANSI standard for C`.

The standard formalizes constructions that were hinted but not described in the first edition, particularly structure assignment and enumerations. It provides a new form of function declaration that permits cross-checking of definition with use. It specifies a standard library, with an extensive set of functions for performing input and output, memory management, string manipulation, and similar tasks. It makes precise the behavior of features that were not spelled out in the original definition, and at the same time states explicitly which aspects of the language remain machine-dependent.

This Second Edition of *The C Programming Language* describes C as defined by the ANSI standard. Although we have noted the places where the language has evolved, we have chosen to write exclusively in the new form. For the most part, this makes no significant difference; the most visible change is the new form of function declaration and definition. Modern compilers already support most features of the standard.

## ISO C

C99 - [ISO/IEC 9899:1999](https://www.iso.org/standard/29237.html)
C11 - [ISO/IEC 9899:2011](https://www.iso.org/standard/57853.html)
C17 - [ISO/IEC 9899:2018](https://www.iso.org/standard/74528.html)

Jens Gustedt - [Modern C v1/2019 ](https://gustedt.gitlabpages.inria.fr/modern-c/) - C versions

As the title of this book suggests, today’s C is not the same language as the one originally designed by its creators, Kernighan and Ritchie (usually referred to as K&R C). In particular, it has undergone an important standardization and extension process, now driven by ISO, the International Standards Organization. This led to the publication of a series of C standards in 1989, 1999, 2011, and 2018, commonly referred to as C89, C99, C11, and C17.

The C standards committee puts a lot of effort into guaranteeing backward compatibility such that code written for earlier versions of the language, say C89, should compile to a semantically equivalent executable with a compiler that implements a newer version. Unfortunately, this backward compatibility has had the unwanted side effect of not motivating projects that could beneﬁt greatly from the new features to update their code base.

[C Programming Language Standard - GeeksforGeeks](https://www.geeksforgeeks.org/c-programming-language-standard/)

## ANSI C and ISO C

[C (programming language)](https://en.wikipedia.org/wiki/C_%28programming_language) - [2.3 ANSI C and ISO C](https://en.wikipedia.org/wiki/C_(programming_language)#ANSI_C_and_ISO_C)

During the late 1970s and 1980s, versions of C were implemented for a wide variety of mainframe computers, minicomputers, and microcomputers, including the IBM PC, as its popularity began to increase significantly.

In 1983, the American National Standards Institute (**ANSI**) formed a committee, X3J11, to establish a standard specification of C. X3J11 based the C standard on the Unix implementation; however, the non-portable portion of the Unix C library was handed off to the IEEE working group 1003 to become the basis for the 1988 POSIX standard. In 1989, the C standard was ratified as ANSI X3.159-1989 "Programming Language C". This version of the language is often referred to as ANSI C, Standard C, or sometimes C89.

In 1990, the ANSI C standard (with formatting changes) was ***adopted*** by the International Organization for Standardization (**ISO**) as ISO/IEC 9899:1990, which is sometimes called C90. Therefore, the terms "C89" and "C90" refer to the same programming language.

ANSI, like other national standards bodies, no longer develops the C standard independently, but defers to the international C standard, maintained by the working group ISO/IEC JTC1/SC22/WG14. National adoption of an update to the international standard typically occurs within a year of ISO publication.

### Difference between C and Ansi C

[Difference between C and Ansi C](https://developerinsider.co/difference-between-c-and-ansi-c/)

[What is difference between ANSI C and C Programming Language?](https://stackoverflow.com/questions/25097010/what-is-difference-between-ansi-c-and-c-programming-language)

### Microsoft ANSI C Conformance

Microsoft Learn: [C++, C, and Assembler](https://learn.microsoft.com/en-us/cpp/?view=msvc-170) | [ANSI C Conformance](https://learn.microsoft.com/en-us/cpp/c-runtime-library/ansi-c-compliance?view=msvc-170)

## C standard library

[C standard library](https://en.wikipedia.org/wiki/C_standard_library)

- [C Standard Library header files - cppreference.com](https://en.cppreference.com/w/c/header)
- [cplusplus.com/reference/clibrary/](https://cplusplus.com/reference/clibrary/)

The Open Group Unix [Headers Index](https://pubs.opengroup.org/onlinepubs/000095399/idx/headers.html)

### libc vs. glibc

GCC stands for GNU Compiler Collection.

[The GNU C Library - GNU Project - Free Software Foundation](https://www.gnu.org/software/libc/)

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

### stdc version

[What is the default C -std standard version for the current GCC (especially on Ubuntu)? - Stack Overflow](https://stackoverflow.com/questions/14737104/what-is-the-default-c-std-standard-version-for-the-current-gcc-especially-on-u)

```Shell title="__STDC_VERSION__"
# ubuntu
$ gcc -dM -E -x c /dev/null | grep -F __STDC_VERSION__
#define __STDC_VERSION__ 201710L

# macOS clang/gcc
gcc -dM -E -x c /dev/null | grep -F __STDC_VERSION__
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
