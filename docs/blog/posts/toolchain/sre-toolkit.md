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

[Blue Fox: Arm Assembly Internals and Reverse Engineering](https://www.amazon.com/Blue-Fox-Assembly-Internals-Analysis/dp/1119745306) | Chapter 10 Static Analysis - Static Analysis Tools

## Disassembler

The process of disassembling a binary includes reconstructing the assembly instructions that the binary would run from their machine-code format into a human-readable assembly language.

Disassembling an executable file can be done in multiple ways, one of the simplest tools to quickly look at the disassembly output of an executable file is the Linux tool `objdump`.

While Linux utilities like `objdump` are useful for quickly disassembling small programs, larger programs require a more convenient solution. Various disassemblers exist to make reverse engineering more efficient, ranging from free open source tools, such as `Ghidra`, to expensive solutions like `IDA Pro`.

## Decompiler

A more recent innovation in reverse engineering is the use of decompilers. Decompilers go a step further than disassemblers. Where disassemblers simply show the human-readable assembly code of the program, decompilers try to regenerate equivalent C/C++ code from a compiled binary.

One value of decompilers is that they significantly reduce and simplify the disassembled output by generating pseudocode. This can make it easier to read when skimming over a function to see at a broad-strokes level what the program is up to.

Disassemblers are used to view the low-level code of a program and come in different flavors and price tags, ranging from free open-source tools such as `Radare2` and `Ghidra` to commercial tools like `Binary Ninja` and `IDA Pro`. Some of them come with decompilation features that attempt to reconstruct the high-level source code of the disassembled program.

## SRE Toolkits

Software Reverse Engineering(SRE) Toolkit:

- [OllyDbg](https://www.ollydbg.de/): frozen, odbg64 incomplete.
- [x64dbg](https://x64dbg.com/): An open-source x64/x32 debugger for windows.

- [radare](https://www.radare.org/n/): UNIX-like reverse engineering framework and command-line toolset
- [Ghidra](https://ghidra-sre.org/): SRE framework developed by NSA's Research Directorate in support of the Cybersecurity mission

- [IDA Pro](https://hex-rays.com/ida-pro/): A powerful disassembler and a versatile debugger.
- [Binary Ninja](https://binary.ninja/): an interactive decompiler, disassembler, debugger, and binary analysis platform.
