---
title: Arm GNU Toolchain
authors:
    - xman
date:
    created: 2023-04-01T10:00:00
categories:
    - arm
    - toolchain
tags:
    - gcc
    - gnueabihf
comments: true
---

How to compile and generate AArch32 code on an AArch64 machine?

[Linaro](https://www.linaro.org/) empowers rapid product deployment within the dynamic Arm ecosystem.

Arm GNU Toolchain is a community supported pre-built GNU compiler toolchain for Arm based CPUs.

<!-- more -->

!!! question "Issues and frequently asked questions"

    [arm64 - Can I run an ARM32 bit App on an ARM64bit platform which is running Ubuntu 16.04 - Ask Ubuntu](https://askubuntu.com/questions/1090351/can-i-run-an-arm32-bit-app-on-an-arm64bit-platform-which-is-running-ubuntu-16-04)
    [arm - how to use aarch64-linux-gnu-objdump to disassemble V7 mode instructions (A32,T32) - Stack Overflow](https://stackoverflow.com/questions/21556051/how-to-use-aarch64-linux-gnu-objdump-to-disassemble-v7-mode-instructions-a32-t3)

    [raspberrypi - Compiling ARMv7A (AArch32) code on an ARMv8A (AArch64) machine? - Ask Ubuntu](https://askubuntu.com/questions/1355339/compiling-armv7a-aarch32-code-on-an-armv8a-aarch64-machine)
    [gcc - Compile and run a 32bit binary on Armv8 (aarch64) running 64bit linux - Stack Overflow](https://stackoverflow.com/questions/68005179/compile-and-run-a-32bit-binary-on-armv8-aarch64-running-64bit-linux)

## bare metal

[Bare machine](https://en.wikipedia.org/wiki/Bare_machine)

In computer science, bare machine (or bare metal) refers to a computer executing instructions directly on logic hardware without an intervening operating system. Modern operating systems evolved through various stages, from elementary to the present day complex, highly sensitive systems incorporating many services.

[ARM 64-Bit Assembly Language](https://www.amazon.com/64-Bit-Assembly-Language-Larry-Pyeatt/dp/0128192216/) | 12 Running without an operating system

Sometimes, it is necessary to write assembly code to run on “bare metal”, which simply means: without an operating system. For example, when we write an operating system kernel, it must run on bare metal and a signiﬁcant part of the code (especially during the boot process) must be written in assembly language.

Coding on bare metal is useful to deeply understand how the hardware works and what happens in the lowest levels of an operating system. There are some signiﬁcant differences between code that is meant to run under an operating system and code that is meant to run on bare metal.

However, there are some software packages to help bare-metal programmers. For example, [Newlib](https://sourceware.org/newlib/) is a C standard library intended for use in bare-metal programs.

## Arm GNU Toolchain

[Arm GNU Toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain) - [Downloads](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)

Arm GNU Toolchain releases consists of cross toolchains for the following host operating systems:

1. GNU/Linux

    - Available for x86_64 and AArch64 host architectures
    - Available for bare-metal and Linux targets

2. Windows

    - Available for x86 host architecture only (compatible with x86_64)
    - Available for bare-metal and Linux targets

3. macOS

    - Available for x86_64 and Apple silicon (beta) host architectures
    - Available for bare-metal targets only

macOS (x86_64/Apple silicon) hosted cross toolchains

- AArch32 bare-metal target (arm-none-eabi)
- AArch64 bare-metal target (aarch64-none-elf)

AArch64 Linux hosted cross toolchains

- AArch32 bare-metal target (arm-none-eabi)
- AArch32 GNU/Linux target with hard float (arm-none-linux-gnueabihf)
- AArch64 ELF bare-metal target (aarch64-none-elf)

## Cross-compiler

[Cross-compiler | Arm Learning Paths](https://learn.arm.com/install-guides/gcc/cross/)

GCC is available on all Linux distributions and can be installed using the package manager.

This covers `gcc` and `g++` for compiling C and C++ as a cross-compiler targeting the Arm architecture.

### notice

GCC is often used to cross-compile software for Arm microcontrollers and embedded devices which have firmware and other low-level software. The executables are `arm-none-eabi-gcc` and `arm-none-eabi-g++`.

GCC is also used to cross compile Linux applications. Applications can be compiled for 32-bit or 64-bit Linux systems.

- The executables for 32-bit are `arm-linux-gnueabihf-gcc` and `arm-linux-gnueabihf-g++`.
- The executables for 64-bit are `aarch64-linux-gnu-gcc` and `aarch64-linux-gnu-g++`.

Software can be compiled on an x86 or Arm host machine.

### installation

Installing on Debian based distributions such as Ubuntu

Use the `apt` command to install software packages on any Debian based Linux distribution.

```bash
$ sudo apt update
$ sudo apt install gcc-arm-none-eabi -y
$ sudo apt install gcc-arm-linux-gnueabihf -y
$ sudo apt install gcc-aarch64-linux-gnu -y
```

You can check and confirm the package description/information before installation.

```bash
$ uname -a
Linux rpi3b-ubuntu 5.15.0-1055-raspi #58-Ubuntu SMP PREEMPT Sat May 4 03:52:40 UTC 2024 aarch64 aarch64 aarch64 GNU/Linux

$ apt search -n gcc-arm-none-eabi
$ apt list gcc-arm-none-eabi
$ apt-cache show gcc-arm-none-eabi
$ apt-cache showpkg gcc-arm-none-eabi
```

=== "gcc-arm-none-eabi"

    ```bash
    $ apt search -n gcc-arm-none-eabi
    Sorting... Done
    Full Text Search... Done
    gcc-arm-none-eabi/jammy 15:10.3-2021.07-4 arm64
    GCC cross compiler for ARM Cortex-R/M processors

    gcc-arm-none-eabi-source/jammy 15:10.3-2021.07-4 all
    GCC cross compiler for ARM Cortex-R/M processors (source)
    ```

=== "gcc-arm-linux-gnueabihf"

    ```bash
    $ apt search -n gcc-arm-linux-gnueabihf
    Sorting... Done
    Full Text Search... Done
    gcc-arm-linux-gnueabihf/jammy 4:11.2.0-1ubuntu1 arm64
    GNU C compiler for the armhf architecture
    ```

=== "gcc-aarch64-linux-gnu"

    ```bash
    $ apt search -n gcc-aarch64-linux-gnu
    Sorting... Done
    Full Text Search... Done

    $ apt search -n gcc
    Sorting... Done
    Full Text Search... Done
    cross-gcc-dev/jammy 246 all
    Tools for building cross-compilers and cross-compiler packages

    gcc/jammy,now 4:11.2.0-1ubuntu1 arm64 [installed]
    GNU C compiler

    gcc-10/jammy-updates,jammy-security 10.5.0-1ubuntu1~22.04 arm64
    GNU C compiler

    gcc-10-arm-linux-gnueabi/jammy-updates,jammy-security 10.5.0-1ubuntu1~22.04cross1 arm64
    GNU C compiler (cross compiler for armel architecture)

    gcc-10-arm-linux-gnueabi-base/jammy-updates,jammy-security 10.5.0-1ubuntu1~22.04cross1 arm64
    GCC, the GNU Compiler Collection (base package)

    gcc-10-arm-linux-gnueabihf/jammy-updates,jammy-security 10.5.0-1ubuntu1~22.04cross1 arm64
    GNU C compiler (cross compiler for armhf architecture)

    gcc-10-arm-linux-gnueabihf-base/jammy-updates,jammy-security 10.5.0-1ubuntu1~22.04cross1 arm64
    GCC, the GNU Compiler Collection (base package)

    ...
    ```

### Get started

To confirm the installation is successful, enter:

```bash
$ arm-none-eabi-gcc --version

# newly installed
pifan@rpi3b-ubuntu $ arm-linux-gnueabihf-gcc --version
arm-linux-gnueabihf-gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# previously installed
pifan@rpi3b-ubuntu $ aarch64-linux-gnu-gcc --version
aarch64-linux-gnu-gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

To cross-compile hello-world as a 32-bit Linux application. On Fedora, only building kernels is currently supported. Support for cross-building user space programs is not currently provided as that would massively multiply the number of packages.

```bash
$ arm-linux-gnueabihf-gcc hello-world-embedded.c -o hello-world.elf
```

To cross-compile hello-world as a 64-bit Linux application. On Fedora, only building kernels is currently supported. Support for cross-building user space programs is not currently provided as that would massively multiply the number of packages.

```bash
$ aarch64-linux-gnu-gcc hello-world-embedded.c -o hello-world.elf
```

## references

[Toolchains](http://web.eecs.umich.edu/~prabal/teaching/eecs373-f12/notes/notes-toolchain.pdf)

[radcolor/arm-linux-gnueabi](https://github.com/radcolor/arm-linux-gnueabi)
[radcolor/aarch64-linux-gnu](https://github.com/radcolor/aarch64-linux-gnu)

[arm-linux-gnu-gcc(1) - Linux man page](https://linux.die.net/man/1/arm-linux-gnu-gcc)
[aarch64-linux-gnu-gcc(1) - Linux man page](https://linux.die.net/man/1/aarch64-linux-gnu-gcc)

[32 Bit executables in AARCH64 system - ODROID](https://forum.odroid.com/viewtopic.php?t=18806)
[linux - Running 32-bit ARM binary on aarch64 not working despite CONFIG_COMPAT - Stack Overflow](https://stackoverflow.com/questions/59379848/running-32-bit-arm-binary-on-aarch64-not-working-despite-config-compat)
[How to run 32-bit (armhf) binaries on 64-bit (arm64) Debian OS on Raspberry Pi? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/625576/how-to-run-32-bit-armhf-binaries-on-64-bit-arm64-debian-os-on-raspberry-pi)

[What is the difference between arm-linux-gcc and arm-none-linux-gnueabi - Stack Overflow](https://stackoverflow.com/questions/13797693/what-is-the-difference-between-arm-linux-gcc-and-arm-none-linux-gnueabi)
[20.04 - How to install "gcc-arm-linux-gnueabihf" specific version? - Ask Ubuntu](https://askubuntu.com/questions/1448687/how-to-install-gcc-arm-linux-gnueabihf-specific-version)

[交叉编译工具 gcc-aarch64-linux-gnu 的介绍与安装](https://blog.csdn.net/song_lee/article/details/105487177)
[linux安装交叉编译器gcc-arm-linux-gnueabi](https://blog.csdn.net/qq_39397165/article/details/103252179)
