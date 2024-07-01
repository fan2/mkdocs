---
title: C Programming Language Standard
authors:
  - xman
date:
    created: 2009-10-01T10:00:00
    updated: 2024-03-29T10:00:00
categories:
    - c
tags:
    - standard
    - library
comments: true
---

C Programming Language Standard from ANSI C to ISO C and standard library.

<!-- more -->

## wiki

[C (programming language)](https://en.wikipedia.org/wiki/C_(programming_language))

C is a general-purpose computer programming language.

C is an imperative procedural language, supporting structured programming, lexical variable scope, and recursion, with a static type system.

C is an imperative, procedural language in the [ALGOL](https://en.wikipedia.org/wiki/ALGOL) tradition. It has a static type system. In C, all executable code is contained within subroutines (also called "functions", though not in the sense of [functional programming](https://en.wikipedia.org/wiki/Functional_programming)).

It was created in the 1970s by [Dennis Ritchie](https://www.bell-labs.com/usr/dmr/www/), and remains very widely used and influential. By design, C's features cleanly **reflect** the capabilities of the targeted CPUs. It has found lasting use in operating systems, device drivers, and protocol stacks, but its use in application software has been decreasing. C is commonly used on computer architectures that range from the largest supercomputers to the smallest microcontrollers and embedded systems.

C has been standardized since 1989 by the American National Standards Institute (ANSI) and the International Organization for Standardization (ISO).

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

The C standards committee puts a lot of effort into guaranteeing backward compatibility such that code written for earlier versions of the language, say C89, should compile to a semantically equivalent executable with a compiler that implements a newer version. Unfortunately, this backward compatibility has had the unwanted side effect of not motivating projects that could benefit greatly from the new features to update their code base.

[C Programming Language Standard - GeeksforGeeks](https://www.geeksforgeeks.org/c-programming-language-standard/)

## ANSI C vs. ISO C

[C (programming language)](https://en.wikipedia.org/wiki/C_(programming_language)) - [2.3 ANSI C and ISO C](https://en.wikipedia.org/wiki/C_(programming_language)#ANSI_C_and_ISO_C)

During the late 1970s and 1980s, versions of C were implemented for a wide variety of mainframe computers, minicomputers, and microcomputers, including the IBM PC, as its popularity began to increase significantly.

In 1983, the American National Standards Institute (**ANSI**) formed a committee, X3J11, to establish a standard specification of C. X3J11 based the C standard on the Unix implementation; however, the non-portable portion of the Unix C library was handed off to the IEEE working group 1003 to become the basis for the 1988 POSIX standard. In 1989, the C standard was ratified as ANSI X3.159-1989 "Programming Language C". This version of the language is often referred to as ANSI C, Standard C, or sometimes C89.

In 1990, the ANSI C standard (with formatting changes) was ***adopted*** by the International Organization for Standardization (**ISO**) as ISO/IEC 9899:1990, which is sometimes called C90. Therefore, the terms "C89" and "C90" refer to the same programming language.

ANSI, like other national standards bodies, no longer develops the C standard independently, but defers to the international C standard, maintained by the working group ISO/IEC JTC1/SC22/WG14. National adoption of an update to the international standard typically occurs within a year of ISO publication.

---

[Difference between C and Ansi C](https://developerinsider.co/difference-between-c-and-ansi-c/)

[What is difference between ANSI C and C Programming Language?](https://stackoverflow.com/questions/25097010/what-is-difference-between-ansi-c-and-c-programming-language)

Microsoft Learn: [C++, C, and Assembler](https://learn.microsoft.com/en-us/cpp/?view=msvc-170) | [ANSI C Conformance](https://learn.microsoft.com/en-us/cpp/c-runtime-library/ansi-c-compliance?view=msvc-170)

## Standard Library

[C standard library](https://en.wikipedia.org/wiki/C_standard_library)

- [C Standard Library header files - cppreference.com](https://en.cppreference.com/w/c/header)
- [cplusplus.com/reference/clibrary/](https://cplusplus.com/reference/clibrary/)

### GNU C

The Open Group Unix [Headers Index](https://pubs.opengroup.org/onlinepubs/000095399/idx/headers.html)

[The GNU C Library](https://www.gnu.org/software/libc/)
[The GNU C Reference Manual](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html)

### Other

[uClibc](https://www.uclibc.org/) - C library for developing embedded Linux systems
[diet libc](https://www.fefe.de/dietlibc/) - a libc optimized for small size
[musl libc](https://musl.libc.org/) - an implementation of the C standard library

[Newlib](https://sourceware.org/newlib/) @[wiki](https://en.wikipedia.org/wiki/Newlib)

- newlib-cygwin: @[git](git://sourceware.org/git/newlib-cygwin.git), @[github](https://github.com/mirror/newlib-cygwin)

## ref books

[C Programming Language, 2nd Edition - 1988](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/)

- Author: Brian W. Kernighan, Dennis M. Ritchie
- @[princeton](https://www.cs.princeton.edu/~bwk/cbook.html), PDF@[nju](http://cslabcms.nju.edu.cn/problem_solving/images/c/cc/The_C_Programming_Language_%282nd_Edition_Ritchie_Kernighan%29.pdf)

Jens Gustedt - [Modern C](https://gustedt.gitlabpages.inria.fr/modern-c/)

- [Modern C, Third Edition](https://www.manning.com/books/modern-c-third-edition)

[Modern C for Absolute Beginners: A Friendly Introduction to the C Programming Language](https://www.amazon.com/Modern-Absolute-Beginners-Introduction-Programming/dp/1484266420), 2e-2024

Programming from the Ground Up: Bartlett, Jonathan

- [2004](https://www.amazon.com/Programming-Ground-Up-Jonathan-Bartlett/dp/0975283847) - @[gnu.org](https://download-mirror.savannah.gnu.org/releases/pgubook/ProgrammingGroundUp-1-0-booksize.pdf)  
- [2009](https://www.amazon.com/Programming-Ground-Up-Jonathan-Bartlett/dp/1616100648)  

[Low-Level Programming: C, Assembly, and Program Execution on Intel® 64 Architecture](https://www.amazon.com/Low-Level-Programming-Assembly-Execution-Architecture/dp/1484224027), 1e-2017

- hservers PDF - [Low Level Programming.pdf](https://www.hservers.org/kobo/IT/Low%20Level%20Programming.pdf)
- hservers webview - [Low Level Programming.pdf](https://hservers.org/pdfjs/web/viewer.html?file=/kobo/IT/Low%20Level%20Programming.pdf)

[《C语言深度解剖（第3版）》(陈正冲)](https://item.jd.com/12720594.html) - 2008,2012,2019
[C语言标准与实现(姚新颜)-2004](https://att.newsmth.net/nForum/att/CProgramming/3213/245)
[老码识途-从机器码到框架的系统观逆向修炼之路-2012](https://book.douban.com/subject/19930393/)
