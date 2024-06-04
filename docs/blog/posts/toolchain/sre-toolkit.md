---
title: Software Reverse Engineering Toolkits
authors:
  - xman
date:
    created: 2023-10-01T09:00:00
categories:
    - toolchain
tags:
    - disassemble
    - discompile
comments: true
---

You can debug a program from the command line using `GDB` or even more powerful tools such as `Radare2`, `IDA Pro` and `Binary Ninja`.

<!-- more -->

[Practical Binary Analysis](https://www.amazon.com/Practical-Binary-Analysis-Instrumentation-Disassembly/dp/1593279124) | Chapter 6: Disassembly and Binary Analysis Fundamentals

[Arm Assembly Internals and Reverse Engineering](https://www.amazon.com/Blue-Fox-Assembly-Internals-Analysis/dp/1119745306) | Chapter 10 Static Analysis - Static Analysis Tools

## Disassembler

The process of disassembling a binary includes reconstructing the assembly instructions that the binary would run from their machine-code format into a human-readable assembly language.

Disassembling an executable file can be done in multiple ways, one of the simplest tools to quickly look at the disassembly output of an executable file is the Linux tool `objdump`.

While Linux utilities like `objdump` are useful for quickly disassembling small programs, larger programs require a more convenient solution. Various disassemblers exist to make reverse engineering more efficient, ranging from free open source tools, such as `Ghidra`, to expensive solutions like `IDA Pro`.

## Decompiler

A more recent innovation in reverse engineering is the use of decompilers. Decompilers go a step further than disassemblers. Where disassemblers simply show the human-readable assembly code of the program, decompilers try to regenerate equivalent C/C++ code from a compiled binary.

One value of decompilers is that they significantly reduce and simplify the disassembled output by generating pseudocode. This can make it easier to read when skimming over a function to see at a broad-strokes level what the program is up to.

Disassemblers are used to view the low-level code of a program and come in different flavors and price tags, ranging from free open-source tools such as `Radare2` and `Ghidra` to commercial tools like `Binary Ninja` and `IDA Pro`. Some of them come with decompilation features that attempt to reconstruct the high-level source code of the disassembled program.

## SRE Toolkits

[Practical Binary Analysis](https://www.amazon.com/Practical-Binary-Analysis-Instrumentation-Disassembly/dp/1593279124) | Appendix C: List of Binary Analysis Tools - Disassemblers

Software Reverse Engineering(SRE) Toolkit:

- [OllyDbg](https://www.ollydbg.de/): frozen, odbg64 incomplete.
- [x64dbg](https://x64dbg.com/): An open-source x64/x32 debugger for windows.

- [radare](https://www.radare.org/n/): UNIX-like reverse engineering framework and command-line toolset
- [Ghidra](https://ghidra-sre.org/): SRE framework developed by NSA's Research Directorate in support of the Cybersecurity mission

- [IDA Pro](https://hex-rays.com/ida-pro/): A powerful disassembler and a versatile debugger.
- [Binary Ninja](https://binary.ninja/): an interactive decompiler, disassembler, debugger, and binary analysis platform.

- [rscloura/Doldrums](https://github.com/rscloura/Doldrums): A Flutter/Dart reverse engineering tool.

## references

[Compiler Explorer](https://gcc.godbolt.org/) @[github](https://github.com/compiler-explorer/compiler-explorer)

- Run compilers interactively from your web browser and interact with the assembly

### forums

[web forums focusing on reverse engineering](https://www.quora.com/What-are-some-popular-web-forums-focusing-on-reverse-engineering)

[r/Reverse Engineering](https://www.reddit.com/r/ReverseEngineering/)
[Reverse Engineering Stack Exchange](https://reverseengineering.stackexchange.com/)

[Red Team Notes](https://www.ired.team/) / [BlackHatWorld](https://www.blackhatworld.com/tags/reverse-engineering/)
[Crackmes](https://crackmes.one/) / [Root Me](https://www.root-me.org/?lang=en)
[Reversing.Kr](http://reversing.kr/) / [Exploit Database](https://www.exploit-db.com/)
[HackTricks](https://book.hacktricks.xyz/) / [Phrack Magazine](http://phrack.org/issues/1/1.html)

[看雪学苑](https://www.kanxue.com/), [飘云阁](https://www.chinapyg.com/), [吾爱破解](https://www.52pojie.cn/)

### courses

[Reverse Engineering for Beginners](https://beginners.re/)
[Reverse Engineering For Everyone!](https://0xinfection.github.io/reversing/)

[CSC 472/583 Software Security - 2021-Fall Course Website](https://www.cs.wcupa.edu/schen/ss2021/)
[CSC 495/583 Topics of Software Security - 2023-Fall Course Website](https://www.cs.wcupa.edu/schen/ss2023/)

### CTF Notes

[CTF Handbook](https://ctf101.org/)
[Introduction | Note: CTF](https://fareedfauzi.gitbook.io/ctf-playbook)
[Advanced Binary Exploitation CTF](https://reverseengineering.stackexchange.com/questions/26764/advanced-binary-exploitation-ctf)
[Linux Reverse Engineering CTFs for Beginners](https://osandamalith.com/2019/02/11/linux-reverse-engineering-ctfs-for-beginners/)

### doorstep

[xairy/easy-linux-pwn](https://github.com/xairy/easy-linux-pwn)
[xairy/linux-kernel-exploitation](https://github.com/xairy/linux-kernel-exploitation)
[nnamon/linux-exploitation-course](https://github.com/nnamon/linux-exploitation-course)
[Exploit Education :: Andrew Griffiths' Exploit Education](https://exploit.education/)

[Binary Exploitation Notes | Binary Exploitation](https://ir0nstone.gitbook.io/notes)
[TryHackMe: Reversing ELF. tryhackme Reversing ELF write-up](https://medium.com/@xiosec/tryhackme-reversing-elf-60ab96969e41)

[exploit-exercises](https://exploit-exercises.com/)
[bkerler/exploit_me](https://github.com/bkerler/exploit_me)
[Defeating ioli with radare2](https://dustri.org/b/defeating-ioli-with-radare2.html)

### series

[A Noob's Guide To ARM Exploitation](https://ad2001.gitbook.io/a-noobs-guide-to-arm-exploitation)

[ARM binary exploitation — Aaarchibald WriteUP](https://medium.com/@chackal/arm-binary-exploitation-aaarchibald-writeup-dd4ae9cd8370)

[Introduction to Return-Oriented Exploitation on ARM64](https://www.slideshare.net/slideshow/introduction-to-returnoriented-exploitation-on-arm64-billy-ellis/110144234)

ARM64 Reversing And Exploitation: [1](https://8ksec.io/arm64-reversing-and-exploitation-part-1-arm-instruction-set-simple-heap-overflow/), [2](https://8ksec.io/arm64-reversing-and-exploitation-part-2-use-after-free/), [3](https://8ksec.io/arm64-reversing-and-exploitation-part-3-a-simple-rop-chain/), [4](https://8ksec.io/arm64-reversing-and-exploitation-part-4-using-mprotect-to-bypass-nx-protection-8ksec-blogs/), [5](https://8ksec.io/arm64-reversing-and-exploitation-part-5-writing-shellcode-8ksec-blogs/), [6](https://8ksec.io/arm64-reversing-and-exploitation-part-6-exploiting-an-uninitialized-stack-variable-vulnerability/), [7](https://8ksec.io/arm64-reversing-and-exploitation-part-7-bypassing-aslr-and-nx/), [8](https://8ksec.io/arm64-reversing-and-exploitation-part-8-exploiting-an-integer-overflow-vulnerability/), [9](https://8ksec.io/arm64-reversing-and-exploitation-part-9-exploiting-an-off-by-one-overflow-vulnerability/)

---

[ARM64 Reverse Engineering and Exploitation Training (November 2018)](http://antid0te-sg.com/blog/18-11-12-arm64-reverse-engineering-exploitation-singapore.html)

Introduction to x64 Linux Binary Exploitation: [1](https://valsamaras.medium.com/introduction-to-x64-linux-binary-exploitation-part-1-14ad4a27aeef), [2](https://valsamaras.medium.com/introduction-to-x64-binary-exploitation-part-2-return-into-libc-c325017f465), [3](https://valsamaras.medium.com/introduction-to-x64-linux-binary-exploitation-part-3-rop-chains-3cdcf17e8826), [4](https://valsamaras.medium.com/introduction-to-x64-linux-binary-exploitation-part-4-stack-canaries-e9b6dd2c3127), [5](https://valsamaras.medium.com/introduction-to-x64-linux-binary-exploitation-part-5-aslr-394d0dc8e4fb)

[The Offensive Labs](https://www.theoffensivelabs.com/) - [Exploit Development for Linux (x86_64)](https://www.theoffensivelabs.com/courses/1189391/lectures/25930693)
