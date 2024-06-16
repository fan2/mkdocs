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

    - [Rizin](https://rizin.re/): a fork of the radare2
    - [Cutter](https://cutter.re/): Rizin's official GUI

- [Ghidra](https://ghidra-sre.org/): SRE framework developed by NSA's Research Directorate in support of the Cybersecurity mission

    - [Ghidra Software Reverse Engineering for Beginners](https://www.amazon.com/Ghidra-Software-Reverse-Engineering-Beginners/dp/1800207972)

- [IDA Pro](https://hex-rays.com/ida-pro/): A powerful disassembler and a versatile debugger.
- [Binary Ninja](https://binary.ninja/): an interactive decompiler, disassembler, debugger, and binary analysis platform.

- [Capstone](https://www.capstone-engine.org/): The Ultimate Disassembly Framework - [introduction](https://www.blackhat.com/docs/us-14/materials/us-14-NguyenAnh-Capstone-Next-Generation-Disassembly-Framework.pdf)
- [rscloura/Doldrums](https://github.com/rscloura/Doldrums): A Flutter/Dart reverse engineering tool.

## references

[Compiler Explorer](https://gcc.godbolt.org/) @[github](https://github.com/compiler-explorer/compiler-explorer)
[An Empirical Study on ARM Disassembly Tools](https://www4.comp.polyu.edu.hk/~csxluo/ARM.pdf)

[CSC 472/583 Software Security - 2021-Fall Course Website](https://www.cs.wcupa.edu/schen/ss2021/)
[CSC 495/583 Topics of Software Security - 2023-Fall Course Website](https://www.cs.wcupa.edu/schen/ss2023/)

### forums

[web forums focusing on reverse engineering](https://www.quora.com/What-are-some-popular-web-forums-focusing-on-reverse-engineering)

[r/Reverse Engineering](https://www.reddit.com/r/ReverseEngineering/)
[Reverse Engineering Stack Exchange](https://reverseengineering.stackexchange.com/)

[Red Team Notes](https://www.ired.team/) / [BlackHatWorld](https://www.blackhatworld.com/tags/reverse-engineering/)
[HackTricks](https://book.hacktricks.xyz/) / [Phrack Magazine](http://phrack.org/issues/1/1.html)

[看雪学苑](https://www.kanxue.com/), [飘云阁](https://www.chinapyg.com/), [吾爱破解](https://www.52pojie.cn/)

### collections

[Advanced Binary Exploitation CTF](https://reverseengineering.stackexchange.com/questions/26764/advanced-binary-exploitation-ctf)
[easy-linux-pwn](https://github.com/xairy/easy-linux-pwn), [linux-kernel-exploitation](https://github.com/xairy/linux-kernel-exploitation)

[Crackmes](https://crackmes.one/) / [Root Me](https://www.root-me.org/?lang=en)
[Reversing.Kr](http://reversing.kr/) / [Exploit Database](https://www.exploit-db.com/)
[exploit-exercises](https://exploit-exercises.com/), [Exploit Education](https://exploit.education/)

### CTF Notes

[Note: CTF](https://fareedfauzi.gitbook.io/ctf-playbook)
[CTF101 - CTF Handbook](https://ctf101.org/)
[Binary Exploitation Notes](https://ir0nstone.gitbook.io/notes)
[nnamon/linux-exploitation-course](https://github.com/nnamon/linux-exploitation-course)
[CTF-All-In-One 《CTF 竞赛入门指南》](https://firmianay.gitbooks.io/ctf-all-in-one/)

### Reverse Engineering

[Linux Reverse Engineering CTFs for Beginners](https://osandamalith.com/2019/02/11/linux-reverse-engineering-ctfs-for-beginners/)
[TryHackMe: Reversing ELF.](https://medium.com/@xiosec/tryhackme-reversing-elf-60ab96969e41) - [reverselfiles](https://tryhackme.com/r/room/reverselfiles)

[Reverse Engineering for Beginners](https://beginners.re/)
[Reverse Engineering For Everyone!](https://0xinfection.github.io/reversing/)

[Reverse Engineering on macOS](https://gist.github.com/0xdevalias/256a8018473839695e8684e37da92c25)
[How To Reverse Malware on macOS](https://go.sentinelone.com/rs/327-MNM-087/images/reverse_mw_final_9.pdf)

### Binary Exploitation

[A Noob's Guide To ARM Exploitation](https://ad2001.gitbook.io/a-noobs-guide-to-arm-exploitation)
[bkerler/exploit_me](https://github.com/bkerler/exploit_me) - ARM/AARCH64

ARM binary exploitation: [Aaarchibald](https://medium.com/@chackal/arm-binary-exploitation-aaarchibald-writeup-dd4ae9cd8370), [Armory](https://medium.com/@chackal/arm-binary-exploitation-armory-writeup-e6468b18b068), [RET2ZP](https://medium.com/@chackal/ret2zp-arm-binary-exploitation-hola-armigo-writeup-77c4a673dd0b)
[Introduction to Return-Oriented Exploitation on ARM64](https://www.slideshare.net/slideshow/introduction-to-returnoriented-exploitation-on-arm64-billy-ellis/110144234)

ARM64 Reversing and Exploitation: [1](https://highaltitudehacks.com/2020/09/05/arm64-reversing-and-exploitation-part-1-arm-instruction-set-heap-overflow.html), [2](https://highaltitudehacks.com/2020/09/06/arm64-reversing-and-exploitation-part-2-use-after-free.html), [3](https://highaltitudehacks.com/2020/09/06/arm64-reversing-and-exploitation-part-3-a-simple-rop-chain.html)
ARM64 Reversing And Exploitation: [1](https://8ksec.io/arm64-reversing-and-exploitation-part-1-arm-instruction-set-simple-heap-overflow/), [2](https://8ksec.io/arm64-reversing-and-exploitation-part-2-use-after-free/), [3](https://8ksec.io/arm64-reversing-and-exploitation-part-3-a-simple-rop-chain/), [4](https://8ksec.io/arm64-reversing-and-exploitation-part-4-using-mprotect-to-bypass-nx-protection-8ksec-blogs/), [5](https://8ksec.io/arm64-reversing-and-exploitation-part-5-writing-shellcode-8ksec-blogs/), [6](https://8ksec.io/arm64-reversing-and-exploitation-part-6-exploiting-an-uninitialized-stack-variable-vulnerability/), [7](https://8ksec.io/arm64-reversing-and-exploitation-part-7-bypassing-aslr-and-nx/), [8](https://8ksec.io/arm64-reversing-and-exploitation-part-8-exploiting-an-integer-overflow-vulnerability/), [9](https://8ksec.io/arm64-reversing-and-exploitation-part-9-exploiting-an-off-by-one-overflow-vulnerability/)

[ARM64 Reverse Engineering and Exploitation Training (November 2018)](http://antid0te-sg.com/blog/18-11-12-arm64-reverse-engineering-exploitation-singapore.html)

---

[Initiating Linux Binary Exploitation: A Beginner's Expedition into Code Manipulation](https://www.kayssel.com/series/binary-exploitation/)

Malware Reverse Engineering for Beginners: [Part 1](https://intezer.com/blog/malware-analysis/malware-reverse-engineering-beginners/), [Part 2](https://intezer.com/blog/incident-response/malware-reverse-engineering-for-beginners-part-2/)
Introduction to x64 Linux Binary Exploitation: [1](https://valsamaras.medium.com/introduction-to-x64-linux-binary-exploitation-part-1-14ad4a27aeef), [2](https://valsamaras.medium.com/introduction-to-x64-binary-exploitation-part-2-return-into-libc-c325017f465), [3](https://valsamaras.medium.com/introduction-to-x64-linux-binary-exploitation-part-3-rop-chains-3cdcf17e8826), [4](https://valsamaras.medium.com/introduction-to-x64-linux-binary-exploitation-part-4-stack-canaries-e9b6dd2c3127), [5](https://valsamaras.medium.com/introduction-to-x64-linux-binary-exploitation-part-5-aslr-394d0dc8e4fb)

[Reverse Engineering Malware | hackers-arise](https://www.hackers-arise.com/reverse-engineering-malware)
[The Offensive Labs](https://www.theoffensivelabs.com/) - [Exploit Development for Linux (x86_64)](https://www.theoffensivelabs.com/courses/1189391/lectures/25930693)
