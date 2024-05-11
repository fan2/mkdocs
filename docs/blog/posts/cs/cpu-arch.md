---
title: CPU Architectures
authors:
  - xman
date:
    created: 2023-03-12T10:00:00
categories:
    - CS
tags:
    - x86
    - arm
    - mips
    - datasheet
comments: true
---

Architecture = [Microarchitecture](https://en.wikipedia.org/wiki/Microarchitecture) + ISA([Instruction set architecture](https://en.wikipedia.org/wiki/Instruction_set_architecture)).

![cpu-architecture-layer](https://www.arm.com/-/media/global/Why%20Arm/architecture/cpu/architecture-layer-diagram-600.png)

有5种指令集最为常见，它们构成了处理器领域的5朵金花。

1. x86——硕大的大象
2. ARM——稳扎稳打的蚁群
3. MIPS——优雅的孔雀
4. Power——昔日的贵族
5. C6000——偏安一隅的独立王国

This article is about the collection of datasheet/textbooks/references on the three major mainstream CPUs.

<!-- more -->

## Intel

**I**ntel **A**rchitecture

[IA-32](https://en.wikipedia.org/wiki/IA-32) / [x86](https://en.wikipedia.org/wiki/X86)  
[IA-64](https://en.wikipedia.org/wiki/IA-64) / [x86-64](https://en.wikipedia.org/wiki/X86-64)  

### datasheet

[Intel® 64 and IA-32 Architectures Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

[Intel® 64 and IA-32 Architectures Software Developer’s Manual Combined Volumes: 1, 2A, 2B, 2C, 2D, 3A, 3B, 3C, 3D, and 4](https://www.intel.com/content/www/us/en/content-details/782158/intel-64-and-ia-32-architectures-software-developer-s-manual-combined-volumes-1-2a-2b-2c-2d-3a-3b-3c-3d-and-4.html?wapkw=intel%2064%20and%20ia-32%20architectures%20software%20developer's%20manual&docid=782158)

[IA-64 Application Developer’s Architecture Guide](https://redirect.cs.umbc.edu/portal/help/architecture/ex_sum.pdf)

### textbooks

1. 《[C语言标准与实现](https://att.newsmth.net/nForum/att/CProgramming/3213/245)》，姚新颜，2004 - #1 基础知识
2. 《[深入理解计算机系统](https://item.jd.com/12006637.html)》，Randal E. Bryant & David R. O'Hallaron, 2015, 3e - 第3章 程序的机器级表示
3. 《[老码识途-从机器码到框架的系统观逆向修炼之路](https://book.douban.com/subject/19930393/)》，韩宏，2012 - 第1章 欲向码途问大道，锵锵bit是吾刀

x86 汇编语言：

1. 《[汇编语言](https://item.jd.com/12841436.html)》，王爽，2019，4e
2. [Professional Assembly Language(IA32)](https://www.amazon.com/Professional-Assembly-Language-Richard-Blum/dp/0764579010), Richard Blum, 2005
3. [Assembly Language For X86 Processors](https://www.amazon.com/Assembly-Language-X86-Processors-Irvine/dp/9352869184), KIP R. IRVINE, 2014, 7e
4. [Introduction to 64 Bit Assembly Programming for Linux and OS X](https://www.amazon.com/Introduction-Bit-Assembly-Programming-Linux/dp/1484921909), Ray Seyfarth, 2014, 3e
5. [Low-Level Programming: C, Assembly, and Program Execution on Intel® 64 Architecture](https://www.amazon.com/Low-Level-Programming-Assembly-Execution-Architecture/dp/1484224027), Igor Zhirkov, 2017
6. [Windows 64-bit Assembly Language Programming Quick Start: Intel X86-64, SSE, AVX](https://www.amazon.com/Windows-64-bit-Assembly-Language-Programming/dp/0970112467), Robert Dunne, 2018
7. [Modern X86 Assembly Language Programming: Covers X86 64-bit, AVX, AVX2, and AVX-512](https://www.amazon.com/Modern-X86-Assembly-Language-Programming/dp/1484296028/), Daniel Kusswurm, 2023, 3e

### references

[Guide to x86 Assembly](https://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html)

## ARM

*A*corn *R*ISC *M*achine(1978) -> *A*dvanced *R*ISC *M*achine(1990).
Arm defines three architecture profiles: Application (**A**), Real-time (**R**), and Microcontroller (**M**).

[ARM architecture family](https://en.wikipedia.org/wiki/ARM_architecture_family)- [Cores](https://en.wikipedia.org/wiki/ARM_architecture#Cores)

- [List of ARM processors](https://en.wikipedia.org/wiki/List_of_ARM_processors)

### docs

[Documentation – Arm Developer](https://developer.arm.com/documentation/)

[Arm CPU Architecture – Arm®](https://www.arm.com/architecture/cpu)

- [A-Profile Architecture](https://developer.arm.com/Architectures/A-Profile%20Architecture)
- [R-Profile Architecture](https://developer.arm.com/Architectures/R-Profile%20Architecture)
- [M-Profile Architecture](https://developer.arm.com/Architectures/M-Profile%20Architecture)

[Learn the architecture](https://developer.arm.com/documentation/102404/0201/?lang=en)

- [Arm A-profile Architecture Registers](https://developer.arm.com/documentation/ddi0601/2024-03/?lang=en)
- [Arm A-profile A64 Instruction Set Architecture](https://developer.arm.com/documentation/ddi0602/2024-03/?lang=en) - [Base Instructions](https://developer.arm.com/documentation/ddi0602/2024-03/Base-Instructions)

- [ARMv7-M Architecture Reference Manual.pdf](https://developer.arm.com/documentation/ddi0403/ee/?lang=en)
- [M-Profile/Armv8-M](https://developer.arm.com/documentation/107656/0101/Introduction-to-Armv8-architecture-and-architecture-profiles)

[Getting Started with Arm Assembly Language](https://developer.arm.com/documentation/107829/0200)

### textbooks

1. [Modern Assembly Language Programming with the ARM Processor](https://www.amazon.com/Modern-Assembly-Language-Programming-Processor-ebook/dp/B01FENFCMS/), Larry D Pyeatt, 2016
2. [ARM 64-Bit Assembly Language](https://www.amazon.com/64-Bit-Assembly-Language-Larry-Pyeatt/dp/0128192216/), Larry D Pyeatt & William Ughetta, 2019
3. [Raspberry Pi Assembly Language Programming: ARM Processor Coding](https://www.amazon.com/Raspberry-Assembly-Language-Programming-Processor/dp/1484252861/), Stephen Smith, 2019
4. [Programming with 64-Bit ARM Assembly Language: Single Board Computer Development for Raspberry Pi and Mobile Devices](https://www.amazon.com/Programming-64-Bit-ARM-Assembly-Language/dp/1484258800/), Stephen Smith, 2020
5. [Modern Arm Assembly Language Programming: Covers Armv8-A 32-bit, 64-bit, and SIMD](https://www.amazon.com/Modern-Assembly-Language-Programming-Armv8/dp/1484262662/), Daniel Kusswurm, 2020
6. [Computer Organization and Design ARM Edition: The Hardware Software Interface](https://www.amazon.com/Computer-Organization-Design-ARM-Architecture/dp/0128017333), David A. Patterson, John L. Hennessy, 2016 @[ustc](http://home.ustc.edu.cn/~louwenqi/reference_books_tools/Computer%20Organization%20and%20Design%20ARM%20edition.pdf)

### references

[RISC-V vs ARM: A Comprehensive Comparison of Processor Architectures](https://www.wevolver.com/article/risc-v-vs-arm)
[A Comparative Study on the Performance of 64-bit ARM Processors](https://www.researchgate.net/publication/372114908_A_Comparative_Study_on_the_Performance_of_64-bit_ARM_Processors)

The Old New Thing:

- [The ARM processor (Thumb-2), part 1: Introduction](https://devblogs.microsoft.com/oldnewthing/20210531-00/?p=105265)
- [The AArch64 processor (aka arm64), part 1: Introduction](https://devblogs.microsoft.com/oldnewthing/20220726-00/?p=106898)

[EECS 373: Design of Microprocessor-Based Systems](https://people.eecs.berkeley.edu/~prabal/teaching/eecs373-f10/index.html) - [ARM_Architecture_Overview.ppt](https://web.eecs.umich.edu/~prabal/teaching/eecs373-f10/readings/ARM_Architecture_Overview.pdf)

[ARM Assembly By Example](https://armasm.com/)
[ARM Assembly | Azeria Labs](https://azeria-labs.com/writing-arm-assembly-part-1/)

[GNU-ARM-Assy-Quick-Ref.doc](https://www.ic.unicamp.br/~celio/mc404-2014/docs/gnu-arm-directives.pdf)
[ARM® Instruction Set Quick Reference Card](https://pages.cs.wisc.edu/~markhill/restricted/arm_isa_quick_reference.pdf)

[GNU-Syntax Arm Assembly Language Reference Guide — TI Arm Clang Compiler Tools User's Guide](https://software-dl.ti.com/codegen/docs/tiarmclang/compiler_tools_user_guide/gnu_syntax_arm_asm_language/index.html)

## MIPS

**M**icroprocessor without **I**nterlocked **P**ipeline **S**tages

[MIPS](https://en.wikipedia.org/wiki/MIPS_architecture)
[MIPS architecture processors](https://en.wikipedia.org/wiki/MIPS_architecture_processors)

官网：[MIPS Processor, RISC-V, Innovate Compute](https://mips.com/)

### datasheet

amazonaws.com:

- [MIPS® Architecture For Programmers Volume I-A: Introduction to the MIPS32® Architecture](https://s3-eu-west-1.amazonaws.com/downloads-mips/documents/MD00082-2B-MIPS32INT-AFP-06.01.pdf) - 2016
- [MIPS® Architecture for Programmers Volume II-A: The MIPS32® Instruction Set Manual](https://s3-eu-west-1.amazonaws.com/downloads-mips/documents/MD00086-2B-MIPS32BIS-AFP-6.06.pdf) - 2016

- [MIPS® Architecture For Programmers Volume I-A: Introduction to the MIPS64® Architecture](https://s3-eu-west-1.amazonaws.com/downloads-mips/documents/MD00083-2B-MIPS64INT-AFP-06.01.pdf) - 2014
- [MIPS® Architecture For Programmers Volume II-A: The MIPS32® Instruction Set](https://s3-eu-west-1.amazonaws.com/downloads-mips/documents/MD00086-2B-MIPS32BIS-AFP-05.04.pdf) - 2013

ustc.edu:

- [MIPS64® Architecture For Programmers Volume I: Introduction to the MIPS64® Architecture](https://scc.ustc.edu.cn/_upload/article/files/c6/06/45556c084631b2855f0022175eaf/W020100308600768363997.pdf) - 2005
- [MIPS64® Architecture For Programmers Volume II: The MIPS64® Instruction Set](https://scc.ustc.edu.cn/zlsc/lxwycj/200910/W020100308600769158777.pdf) - 2005
- [MIPS64® Architecture For Programmers Volume III: The MIPS64® Privileged Resource Architecture](https://scc.ustc.edu.cn/zlsc/lxwycj/200910/W020100308600770617815.pdf) - 2005

### textbooks

1. [See MIPS Run](https://www.amazon.com/Morgan-Kaufmann-Computer-Architecture-Design/dp/0120884216), Dominic Sweetman, 2006, 2e
2. [Computer Organization and Design RISC-V Edition: The Hardware Software Interface](https://www.amazon.com/Computer-Organization-Design-RISC-V-Architecture/dp/0128122757), David A. Patterson & John L. Hennessy, 2017 @[ustc](http://home.ustc.edu.cn/~louwenqi/reference_books_tools/Computer%20Organization%20and%20Design%20RISC-V%20edition.pdf)

### references

[assembly - where can I find a description of *all* MIPS instructions](https://stackoverflow.com/questions/135896/where-can-i-find-a-description-of-all-mips-instructions)

stanford - [MIPS](https://cs.stanford.edu/people/eroberts/courses/soco/projects/risc/mips/index.html)
[MIPS architecture overview](https://tams.informatik.uni-hamburg.de/applets/hades/webdemos/mips.html)
[Introduction to the MIPS Processor](https://www.scss.tcd.ie/Jeremy.Jones/vivio%205.1/dlx/printable.htm)
[Introduction to the MIPS Architecture and Assembly](https://cs.gordon.edu/courses/cs311/lectures-2021/Introduction%20to%20MIPS.pdf), 2021

[MIPS Assembly Language Programming](https://www.cs.csub.edu/~eddie/cmps2240/doc/britton-mips-text.pdf), 2002
[Programmed Introduction to MIPS Assembly Language](https://chortle.ccsu.edu/AssemblyTutorial/index.html), 2015
[COE 301 Lab - Computer Organization](https://faculty.kfupm.edu.sa/COE/aimane/coe301/lab/) - [Introduction_MIPS_Assembly](https://faculty.kfupm.edu.sa/COE/aimane/coe301/lab/COE301_Lab_2_Introduction_MIPS_Assembly.pdf)
[MIPS Assembly Language (CS 241 Dialect)](https://student.cs.uwaterloo.ca/~cs241/mips/mipsasm.html), 2022

Harvard CS 161:

- [Overview of the MIPS Architecture: Part I](https://www.eecs.harvard.edu/~cs161/notes/mips-part-I.pdf)
- [Overview of the MIPS Architecture: Part II](https://www.eecs.harvard.edu/~cs161/notes/mips-part-II.pdf)

nju-swang: [Lecture 24: Instruction Pipeline(指令流水线)](https://cs.nju.edu.cn/swang/CompArchOrg_13F/slides/lecture24.pdf)

The Old New Thing: [The MIPS R4000, part 1: Introduction](https://devblogs.microsoft.com/oldnewthing/20180402-00/?p=98415)

[SYSTEM V APPLICATION BINARY INTERFACE MIPS RISC Processor Supplement - 3rd Edition](https://refspecs.linuxfoundation.org/elf/mipsabi.pdf)

## refs

[Computer Architecture Lecture 3: ISA Tradeoffs](https://course.ece.cmu.edu/~ece447/s15/lib/exe/fetch.php?media=onur-447-spring15-lecture3-isa-tradeoffs-afterlecture.pdf)

[RISC-V Architecture: A Comprehensive Guide to the Open-Source ISA](https://www.wevolver.com/article/risc-v-architecture)

《ARM 与 x86》 - 作者：王齐
[《大话处理器》](http://blog.csdn.net/muxiqingyang/article/details/6627096) - 万木杨 著

[CPU体系架构-ARM/MIPS/X86](https://nieyong.github.io/wiki_cpu/index.html)
