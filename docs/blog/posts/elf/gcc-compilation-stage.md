---
draft: true
title: GCC Compilation Stage
authors:
    - xman
date:
    created: 2023-06-17T12:00:00
categories:
    - elf
comments: true
---

If you only want some of the stages of compilation, you can use `-x` (or filename suffixes) to tell gcc where to start, and one of the options `-c`, `-S`, or `-E` to say where `gcc` is to stop.

<!-- more -->

## The C Compilation Process

[Practical Binary Analysis](https://www.amazon.com/Practical-Binary-Analysis-Instrumentation-Disassembly/dp/1593279124) | Chapter 1: Anatomy of a Binary

Binaries are produced through *compilation*, which is the process of translating human-readable source code, such as C or C ++ , into machine code that your processor can execute. Figure 1-1 shows the steps involved in a typical compilation process for C code (the steps for C ++ compilation are similar). Compiling C code involves four phases, one of which (awkwardly enough) is also called *compilation*, just like the full compilation process. The phases are `preprocessing`, `compilation`, `assembly`, and `linking`. In practice, modern compilers often merge some or all of these phases, but for demonstration purposes, I will cover them all separately.

![C-compilation-process](./images/C-compilation-process.png)

## gcc stop at specified stage

You can tell `gcc` to stop at a certain stage by passing options.

GCC - [Overall Options](https://gcc.gnu.org/onlinedocs/gcc/Overall-Options.html)

`-E`: Stop after the preprocessing stage; do not run the compiler proper. The output is in the form of preprocessed source code, which is sent to the standard output.

- related post: [Dump Compiler Options](../toolchain/dump-compiler-options.md)

!!! note ""

    [Preprocessor-Options](https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html): Options Controlling the Preprocessor

    `-dletters`: Says to make debugging dumps during compilation as specified by letters(`M`|`D`|`N`|`I`|`U`). The flags documented here are those relevant to the preprocessor. Other letters are interpreted by the compiler proper, or reserved for future versions of GCC, and so are silently ignored. If you specify letters whose behavior conflicts, the result is undefined. See [GCC Developer Options](https://gcc.gnu.org/onlinedocs/gcc/Developer-Options.html), for more information.

    `-P`: Inhibit generation of linemarkers in the output from the preprocessor. This might be useful when running the preprocessor on something that is not C code, and will be sent to a program which might be confused by the linemarkers.

`-S`: Stop after the stage of compilation proper; *do not assemble*. The output is in the form of an assembler code file for each non-assembler input file specified.

- By default, the assembler file name for a source file is made by replacing the suffix ‘.c’, ‘.i’, etc., with ‘`.s`’.

!!! note "-fverbose-asm"

    [Options for Code Generation Conventions](https://gcc.gnu.org/onlinedocs/gcc/Code-Gen-Options.html)

    `-fverbose-asm`: Put extra commentary information in the generated assembly code to make it more readable. This option is generally only of use to those who actually need to read the generated assembly code (perhaps while debugging the compiler itself).

    `-fno-verbose-asm`, the default, causes the extra information to be omitted and is useful when comparing two assembler files.

    The added comments include:

    * information on the compiler version and command-line options,
    * the source code lines associated with the assembly instructions, in the form `FILENAME:LINENUMBER:CONTENT OF LINE`,
    * hints on which high-level expressions correspond to the various assembly instruction operands.

`-c`: Compile or assemble the source files, but *do not link*. The linking stage simply is not done. The ultimate output is in the form of an object file for each source file.

- By default, the object file name for a source file is made by replacing the suffix ‘.c’, ‘.i’, ‘.s’, etc., with ‘`.o`’.

[Linux C编程一站式学习](https://book.douban.com/subject/4141733/) | 第18章 汇编与C之间的关系 - 18.2 main函数、启动例程和退出状态

<figure markdown="span">
    ![gcc命令的选项](./images/gcc-compilation-stage-transition.png){: style="width:75%;height:75%"}
</figure>

[gcc程序的编译过程和链接原理](https://blog.csdn.net/czg13548930186/article/details/78331692):

<figure markdown="span">
    ![gcc-compilation-stage-flow](./images/gcc-compilation-stage-flow.png)
</figure>

[GCC: 编译C语言的流程](https://veryitman.com/2017/10/03/GCC-%E7%BC%96%E8%AF%91C%E8%AF%AD%E8%A8%80%E7%9A%84%E6%B5%81%E7%A8%8B/)

<figure markdown="span">
    ![gcc-compile-procedure](https://veryitman.com/upload/images/2017/10/03/1.jpg)
</figure>
