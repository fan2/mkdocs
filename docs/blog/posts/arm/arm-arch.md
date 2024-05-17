---
title: ARM Architecture
authors:
    - xman
date:
    created: 2023-03-13T12:00:00
categories:
    - arm
tags:
    - profile
    - aarch64
comments: true
---

`ARM` 最初的简称是 *Acorn RISC Machine*。ARM 使用的内核与指令集并不一一对应。

1990年11月，Acorn、Apple 和 VLSI 共同出资创建了 ARM。Acorn RISC Machine 也正式更名为 *Advanced RISC Machine*。

ARM11 之后，ARM 处理器内核不再以 ARM 作为前缀。但 `ARM` 这个单词并没有在 Cortex 系列中消失，Cortex的三大系列 *M-R-A*，合起来就是 ARM。

<!-- more -->

## profiles

[About the Arm architecture](https://developer.arm.com/documentation/102404/0201/About-the-Arm-architecture?lang=en)

- [A-Profile Architecture](https://developer.arm.com/Architectures/A-Profile%20Architecture)
- [R-Profile Architecture](https://developer.arm.com/Architectures/R-Profile%20Architecture)
- [M-Profile Architecture](https://developer.arm.com/Architectures/M-Profile%20Architecture)

The Arm architecture is one of the most popular processor architectures in the world. Billions of Arm-based devices are shipped every year.

The following table describes the three architecture profiles: `A`, `R`, and `M`:

**A**-Profile (Applications) | **R**-Profile (Real-Time) | **M**-Profile (Microcontroller)
-------------------------|-----------------------|----------------------------
High performance | Targeted at systems with real-time requirements | Small, highly power- efficient devices
Designed to run a complex operating system, such as Linux or Windows | Commonly found in networking equipment, and embedded control systems | Found at the heart of many IoT devices

These three profiles allow the Arm architecture to be tailored to the needs of different use cases, while still sharing several base features.

!!! note "Arm brands"

    Arm `Cortex` and Arm `Neoverse` are the brand names that are used for the Arm processor IP offerings. Our partners offer other processor brands using the Arm architecture.

<figure markdown="span">
    <!-- https://documentation-service.arm.com/static/64dcdf2a934840622b3496cf -->
    ![Arm-Arch](./images/Arm_Architecture.png){: style="width:80%;height:80%"}
</figure>

This example smartphone contains the following processor types:

- An **A**-profile processor as the main CPU running a rich OS like Android.
- A cellular modem, based on an **R**-profile processor, provides connectivity.
- Several **M**-profile processors handle operations like system power management.
- The SIM card uses SecurCore, an M-profile processor with additional security features. SecurCore processors are commonly used in smart cards.

[Introduction to the Armv8-M Architecture and its Programmers Model User Guide](https://developer.arm.com/documentation/107656/0101/Introduction-to-Armv8-architecture-and-architecture-profiles):

The `Armv8` architecture has several different profiles. These profiles are variants of the architecture that target different markets and use cases. The Armv8-M architecture is one of these architecture profiles.

Arm defines three architecture profiles: Application (***A***), Real-time (***R***), and Microcontroller (***M***).

## aarch64

[AArch64](https://en.wikipedia.org/wiki/AArch64): `AArch64` or `ARM64` is the 64-bit extension of the ARM architecture family. It was first introduced with the ***Armv8-A*** architecture, and had many extension updates.

```Shell
# mbpa2991-macOS
$ arch
arm64

# rpi4b-ubuntu
$ arch
aarch64
```

Announced in October 2011, **ARMv8-A** represents a fundamental change to the ARM architecture. It adds an optional 64-bit architecture, named "`AArch64`", and the associated new "`A64`" instruction set.

AArch64 provides user-space *compatibility* with the existing 32-bit architecture ("`AArch32`" / ARMv7-A), and instruction set ("`A32`"). The 16-32bit Thumb instruction set is referred to as "`T32`" and has no 64-bit counterpart.

ARMv8-A allows 32-bit applications to be executed in a 64-bit OS, and a 32-bit OS to be under the control of a 64-bit hypervisor.

!!! abstract "aapcs64 - Terms"

    [aapcs64](https://github.com/ARM-software/abi-aa/blob/2a70c42d62e9c3eb5887fa50b71257f20daca6f9/aapcs64/aapcs64.rst) - 2.2 Terms and abbreviations:

    `AArch32`: The 32-bit general-purpose register width *state* of the Armv8 architecture, broadly *compatible* with the Armv7-A architecture.
    `AArch64`: The 64-bit general-purpose register width state of the Armv8 architecture.

ARMv8-A includes the VFPv3/v4 and advanced SIMD (Neon) as standard features in both AArch32 and AArch64. It also adds cryptography instructions supporting AES, SHA-1/SHA-256 and finite field arithmetic.

<figure markdown="span">
    ![AArch64-architecture](./images/AArch64-architecture.png){: style="width:75%;height:75%"}
    <figcaption>A simpliﬁed conceptual view of the AArch64 architecture</figcaption>
</figure>

### Naming conventions

model | Arch | Spec | ISA | Suffixes
------|------|------|-----|---------
64 + 32 bit | AArch64 | ARMv8-A | A64 + A32 | v8-A
32 + 16 (Thumb) bit | AArch32 | ARMv8-R / ARMv7-A | A32 + T32 | -A32 / -R / v7-A.

### AArch64 features

***New instruction set, A64***:

- Has `31` general-purpose 64-bit registers.
- Has dedicated zero or stack pointer (`SP`) register (depending on instruction).
- The program counter (`PC`) is no longer directly accessible as a register.
- Instructions are still ==32== bits long and mostly the same as A32 (with LDM/STM instructions and most conditional execution dropped).

    - Has paired loads/stores (in place of LDM/STM).
    - No predication for most instructions (except branches).

- Most instructions can take 32-bit or 64-bit arguments.
- Addresses assumed to be 64-bit.

***Advanced SIMD (Neon) enhanced***:

- Has 32 × 128-bit registers (up from 16), also accessible via VFPv4.
- Supports double-precision floating-point format.
- Fully IEEE 754 compliant.
- AES encrypt/decrypt and SHA-1/SHA-2 hashing instructions also use these registers.

***A new exception system***: Fewer banked registers and modes.

***Memory translation*** from 48-bit virtual addresses based on the existing Large Physical Address Extension (LPAE), which was designed to be easily extended to 64-bit.

***Extension***: Data gathering hint (ARMv8.0-DGH).

### R & M

AArch64 was introduced in `ARMv8-A` and is included in subsequent versions of ARMv8-A. It was also introduced in `ARMv8-R` as an option, after its introduction in ARMv8-A; it is *not* included in `ARMv8-M`.

!!! info "ARM-R (real-time architecture)"

    Optional AArch64 support was added to the Armv8-R profile, with the first Arm core implementing it being the *Cortex-R82*. It adds the `A64` instruction set, with some changes to the memory barrier instructions.

## products

### Apple

[Apple silicon](https://en.wikipedia.org/wiki/Apple_silicon)

[List of iPhone models](https://en.wikipedia.org/wiki/List_of_iPhone_models)

[List of Apple's mobile device codes types](https://gist.github.com/adamawolf/3048717)

[iPhone chip list: Here's what A-series chip is in each model - 9to5Mac](https://9to5mac.com/2022/07/27/iphone-chip-list/)

[List of Apple processors | Apple Wiki | Fandom](https://apple.fandom.com/wiki/List_of_Apple_processors)

- Apple A7 — (2013) introduced in the iPhone 5S, the company's first 64-bit mobile processor. Also used in the 2nd and 3rd generation iPad minis and 1st generation iPad Air.

### Raspberry Pi

[Processors - Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/computers/processors.html)
[Raspberry Pi Specifications](https://en.wikipedia.org/wiki/Raspberry_Pi#Specifications)

model | Release date | Soc | ISA | CPU
------|--------------|------|-----|----
RPi 3 Model B | Feb 2016 | BCM2837 | ARMv8-A (64/32-bit) | 4× Cortex-A53 1.2 GHz
RPi 4 Model B | Jun 2019​/May 2020 | BCM2711 | ARMv8-A (64/32-bit) | 4× Cortex-A72 1.5 GHz or 1.8 GHz
RPi 5 | Oct 2023 | BCM2712 | ARMv8.2-A (64/32-bit) | 4× Cortex-A76 2.4 GHz

ARMv8-A 64-bit milestones:

- Model A (no Ethernet): Nov 2018
- Model B (with Ethernet) series: since RPi 2 Model B v1.2/Oct 2016​
- Compute Module series: since Jan 2017
- Zero: RPi Zero 2 W/Nov 2015
- Keyboard: RPi 400/Nov 2020

[RPi3 in ARMv8 Mode » Raspberry Pi Geek](https://www.raspberry-pi-geek.com/Archive/2017/23/Operating-the-Raspberry-Pi-3-in-64-bit-mode)

[ARM Reveals Cortex-A72 Architecture Details](https://www.anandtech.com/show/9184/arm-reveals-cortex-a72-architecture-details)
[Cortex-A72 Software Optimization Guide](https://developer.arm.com/documentation/uan0016/a/)

[Arm's Cortex-A76 CPU Unveiled: Taking Aim at the Top for 7nm - Print View](https://www.anandtech.com/print/12785/arm-cortex-a76-cpu-unveiled-7nm-powerhouse)
[Arm Cortex-A76 Software Optimization Guide](https://developer.arm.com/documentation/pjdoc466751330-7215/latest/)

## a64-isa-guide

[A64 Instruction Set Architecture Guide](https://developer.arm.com/documentation/102374/latest/)

1. Overview

- An Instruction Set Architecture (*ISA*) is part of the abstract model of a computer. It deﬁnes how software **controls** the processor.

- The Arm ISA allows you to write software and ﬁrmware that **conforms** to the Arm speciﬁcations. This mean that, if your software or ﬁrmware conforms to the speciﬁcations, any Arm-based processor will execute it in the same way.

2. Why you should care about the ISA?

- As developers, you may not need to write directly in assembler in our day-to-day role. However, assembler is still important in some areas, such as the ﬁrst stage boot software or some low-level kernel activities.

- Even if you are not writing assembly code directly, understanding what the instruction set can do, and how the compiler makes use of those instructions, can help you to write more eﬃcient code. It can also help you to understand the output of the compiler. This can be useful when debugging.

3. Instruction sets in the Arm architecture

- Armv8-A supports three instruction sets: `A32`, `T32` and `A64`.

- The `A64` instruction set is used when executing in the *AArch64 Execution state*. It is a ﬁxed-length ==32==-bit instruction set. The 64 in the name refers to the use of this instruction by the AArch64 Execution state. It does not refer to the size of the instructions in memory.

- The `A32` and `T32` instruction sets are also referred to as `Arm` and `Thumb`, respectively. These instruction sets are used when executing in the *AArch32 Execution state*.

## programming

**User Guide**:

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest)

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest)

- Structure of Assembly Language Modules
- A64 General/Data Transfer Instructions

[Arm Compiler for Embedded User Guide](https://developer.arm.com/documentation/100748/0622?lang=en)

- Assembling Assembly Code
- Embedded Software Development
- Overview of the Linker

[Arm Compiler for Embedded Reference Guide](https://developer.arm.com/documentation/101754/0622)

- Arm Compiler for Embedded Tools Overview

**Quick Reference**:

[GNU ARM Assembler Quick Reference.doc](https://www.ic.unicamp.br/~celio/mc404-2014/docs/gnu-arm-directives.pdf)
[ARM® Instruction Set Quick Reference Card](https://pages.cs.wisc.edu/~markhill/restricted/arm_isa_quick_reference.pdf)
[ARMv8 A64 Quick Reference](https://courses.cs.washington.edu/courses/cse469/19wi/arm64.pdf)
[asmsheets/aarch64.tex](https://github.com/flynd/asmsheets/blob/master/aarch64.tex)

**Arm Assembly**:

[Getting Started with Arm Assembly Language](https://developer.arm.com/documentation/107829/0200) based on Ubuntu 22.04 LTS & Raspberry Pi Zero 2 W.

> The code can be compiled using GNU Compiler Collection ([GCC](https://gcc.gnu.org/)), and the program can run on an Arm Fixed Virtual Platform ([FVP](https://developer.arm.com/Tools%20and%20Software/Fixed%20Virtual%20Platforms)).

tiarmclang - [GNU-Syntax Arm Assembly Language Reference Guide](https://software-dl.ti.com/codegen/docs/tiarmclang/compiler_tools_user_guide/gnu_syntax_arm_asm_language/index.html)

[ARM Assembly | Azeria Labs](https://azeria-labs.com/writing-arm-assembly-part-1/)
[ARM Assembly By Example](https://armasm.com/)

**Assembler**:

[Using as](https://sourceware.org/binutils/docs/as/index.html) - [Index](https://sourceware.org/binutils/docs/as/AS-Index.html) - [ARM-Dependent](https://sourceware.org/binutils/docs/as/ARM_002dDependent.html#ARM_002dDependent)
[ARM Assembler reference | Microsoft Learn](https://learn.microsoft.com/en-us/cpp/assembler/arm/arm-assembler-reference?view=msvc-170)

## references

[ARM vs. Harvard vs. von Neumann](https://www.reddit.com/r/AskElectronics/comments/1dchu7/arm_vs_harvard_vs_von_neumann/)
[GENERAL: Harvard vs von Neumann Architectures](https://developer.arm.com/documentation/ka002816/latest/)
[How to explain the harvard architecture of ARM processor at instruction level?](https://community.arm.com/support-forums/f/architectures-and-processors-forum/8615/how-to-explain-the-harvard-architecture-of-arm-processor-at-instruction-level)
