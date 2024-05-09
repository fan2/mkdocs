---
title: CPU Architectures
authors:
  - xman
date:
    created: 2023-03-12T10:00:00
categories:
    - CS
tags:
    - intel
    - arm
    - mips
    - datasheet
comments: true
---

Architecture = ISA([Instruction set architecture](https://en.wikipedia.org/wiki/Instruction_set_architecture)) + [Microarchitecture](https://en.wikipedia.org/wiki/Microarchitecture).

有5种指令集最为常见，它们构成了处理器领域的5朵金花。

1. x86——硕大的大象
2. ARM——稳扎稳打的蚁群
3. MIPS——优雅的孔雀
4. Power——昔日的贵族
5. C6000——偏安一隅的独立王国

<!-- more -->

## Intel

**I**ntel **A**rchitecture

[IA-32](https://en.wikipedia.org/wiki/IA-32) / [x86](https://en.wikipedia.org/wiki/X86)  
[IA-64](https://en.wikipedia.org/wiki/IA-64) / [x86-64](https://en.wikipedia.org/wiki/X86-64)  

### datasheet

[Intel® 64 and IA-32 Architectures Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

[Intel® 64 and IA-32 Architectures Software Developer’s Manual Combined Volumes: 1, 2A, 2B, 2C, 2D, 3A, 3B, 3C, 3D, and 4](https://www.intel.com/content/www/us/en/content-details/782158/intel-64-and-ia-32-architectures-software-developer-s-manual-combined-volumes-1-2a-2b-2c-2d-3a-3b-3c-3d-and-4.html?wapkw=intel%2064%20and%20ia-32%20architectures%20software%20developer's%20manual&docid=782158)

[IA-64 Application Developer’s Architecture Guide](https://redirect.cs.umbc.edu/portal/help/architecture/ex_sum.pdf)

### references

1. Professional-Assembly-Language(IA32)-2005
2. Windows环境下32位汇编语言程序设计(2e)-2006
3. 王爽-汇编语言(4e)-2019
4. Assembly Language for x86 processors(7e)-2015
5. Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux-2011
6. Modern-X86_64-Assembly-Language-Programming(2e)-2018

## ARM

[ARM architecture family](https://en.wikipedia.org/wiki/ARM_architecture_family)- [Cores](https://en.wikipedia.org/wiki/ARM_architecture#Cores)

- [List of ARM processors](https://en.wikipedia.org/wiki/List_of_ARM_processors)

[AArch64](https://en.wikipedia.org/wiki/AArch64)

### docs

[Documentation – Arm Developer](https://developer.arm.com/documentation/)

[Arm CPU Architecture – Arm®](https://www.arm.com/architecture/cpu)

- [A-Profile Architecture](https://developer.arm.com/Architectures/A-Profile%20Architecture)
- [R-Profile Architecture](https://developer.arm.com/Architectures/R-Profile%20Architecture)
- [M-Profile Architecture](https://developer.arm.com/Architectures/M-Profile%20Architecture)

[Learn the architecture](https://developer.arm.com/documentation/102404/0201/?lang=en)

- [Arm A-profile Architecture Registers](https://developer.arm.com/documentation/ddi0601/2024-03/?lang=en)
- [Arm A-profile A64 Instruction Set Architecture](https://developer.arm.com/documentation/ddi0602/2024-03/?lang=en)
- [ARMv7-M Architecture Reference Manual.pdf](https://developer.arm.com/documentation/ddi0403/ee/?lang=en)
- [M-Profile/Armv8-M](https://developer.arm.com/documentation/107656/0101/Introduction-to-Armv8-architecture-and-architecture-profiles)

### references

[04_ARM_Architecture_Overview.ppt](https://web.eecs.umich.edu/~prabal/teaching/eecs373-f10/readings/ARM_Architecture_Overview.pdf)

The Old New Thing:

- [The ARM processor (Thumb-2), part 1: Introduction](https://devblogs.microsoft.com/oldnewthing/20210531-00/?p=105265)
- [The AArch64 processor (aka arm64), part 1: Introduction](https://devblogs.microsoft.com/oldnewthing/20220726-00/?p=106898)

[RISC-V vs ARM: A Comprehensive Comparison of Processor Architectures](https://www.wevolver.com/article/risc-v-vs-arm)

[A Comparative Study on the Performance of 64-bit ARM Processors](https://www.researchgate.net/publication/372114908_A_Comparative_Study_on_the_Performance_of_64-bit_ARM_Processors)

---

- ARM-64-Bit-Assembly-Language-2020
- Modern-Arm-Assembly-Language-Programming-2020
- Modern-Assembly-Language-Programming-with-ARM-2016
- Programming-with-64-Bit-ARM-Assembly-Language-2020

[Computer Organization and Design ARM Edition: The Hardware Software Interface](https://www.amazon.com/Computer-Organization-Design-ARM-Architecture/dp/0128017333) - 1e-2016 @[ustc](http://home.ustc.edu.cn/~louwenqi/reference_books_tools/Computer%20Organization%20and%20Design%20ARM%20edition.pdf)

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

### references

[assembly - where can I find a description of *all* MIPS instructions](https://stackoverflow.com/questions/135896/where-can-i-find-a-description-of-all-mips-instructions)

[MIPS architecture overview](https://tams.informatik.uni-hamburg.de/applets/hades/webdemos/mips.html)

stanford - [MIPS](https://cs.stanford.edu/people/eroberts/courses/soco/projects/risc/mips/index.html)

Harvard CS 161:

- [Overview of the MIPS Architecture: Part I](https://www.eecs.harvard.edu/~cs161/notes/mips-part-I.pdf)
- [Overview of the MIPS Architecture: Part II](https://www.eecs.harvard.edu/~cs161/notes/mips-part-II.pdf)

The Old New Thing:

- [The MIPS R4000, part 1: Introduction](https://devblogs.microsoft.com/oldnewthing/20180402-00/?p=98415)

---

[See MIPS Run, 2e-2006](https://www.amazon.com/Morgan-Kaufmann-Computer-Architecture-Design/dp/0120884216)
[Computer Organization and Design RISC-V Edition: The Hardware Software Interface](https://www.amazon.com/Computer-Organization-Design-RISC-V-Architecture/dp/0128122757) - 1e-2017 @[ustc](http://home.ustc.edu.cn/~louwenqi/reference_books_tools/Computer%20Organization%20and%20Design%20RISC-V%20edition.pdf)

## refs

[Computer Architecture Lecture 3: ISA Tradeoffs](https://course.ece.cmu.edu/~ece447/s15/lib/exe/fetch.php?media=onur-447-spring15-lecture3-isa-tradeoffs-afterlecture.pdf)

[RISC-V Architecture: A Comprehensive Guide to the Open-Source ISA](https://www.wevolver.com/article/risc-v-architecture)

《ARM 与 x86》 - 作者：王齐
[《大话处理器》](http://blog.csdn.net/muxiqingyang/article/details/6627096) - 万木杨 著
