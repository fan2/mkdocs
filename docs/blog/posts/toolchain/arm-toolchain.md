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

### binutils

We can use `ls`, `grep` and `find` commands to filter `arm-linux-gnueabihf-*` in dir /usr/bin to check the packed binutils.

1. filter all executables:

```bash title="/usr/bin/arm-linux-gnueabihf-*" linenums="1"
$ find /usr/bin ! -type l -name "arm-linux-gnueabihf-*" | xargs ls -l
-rwxr-xr-x 1 root root    31208  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-addr2line
-rwxr-xr-x 1 root root    63760  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-ar
-rwxr-xr-x 1 root root  1134240  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-as
-rwxr-xr-x 1 root root    26680  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-c++filt
-rwxr-xr-x 1 root root  1408056  5月 30  2023 /usr/bin/arm-linux-gnueabihf-cpp-11
-rwxr-xr-x 1 root root  3546752  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-dwp
-rwxr-xr-x 1 root root    39432  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-elfedit
-rwxr-xr-x 1 root root  1403960  5月 30  2023 /usr/bin/arm-linux-gnueabihf-gcc-11
-rwxr-xr-x 1 root root    31216  5月 30  2023 /usr/bin/arm-linux-gnueabihf-gcc-ar-11
-rwxr-xr-x 1 root root    31216  5月 30  2023 /usr/bin/arm-linux-gnueabihf-gcc-nm-11
-rwxr-xr-x 1 root root    31216  5月 30  2023 /usr/bin/arm-linux-gnueabihf-gcc-ranlib-11
-rwxr-xr-x 1 root root   733344  5月 30  2023 /usr/bin/arm-linux-gnueabihf-gcov-11
-rwxr-xr-x 1 root root   557080  5月 30  2023 /usr/bin/arm-linux-gnueabihf-gcov-dump-11
-rwxr-xr-x 1 root root   581736  5月 30  2023 /usr/bin/arm-linux-gnueabihf-gcov-tool-11
-rwxr-xr-x 1 root root   102008  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-gprof
-rwxr-xr-x 1 root root   794112  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-ld.bfd
-rwxr-xr-x 1 root root  5772008  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-ld.gold
-rwxr-xr-x 1 root root 22271080  5月 30  2023 /usr/bin/arm-linux-gnueabihf-lto-dump-11
-rwxr-xr-x 1 root root    52600  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-nm
-rwxr-xr-x 1 root root   182600  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-objcopy
-rwxr-xr-x 1 root root   431056  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-objdump
-rwxr-xr-x 1 root root    63768  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-ranlib
-rwxr-xr-x 1 root root   801136  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-readelf
-rwxr-xr-x 1 root root    30944  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-size
-rwxr-xr-x 1 root root    35200  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-strings
-rwxr-xr-x 1 root root   182608  1月 23 23:08 /usr/bin/arm-linux-gnueabihf-strip
```

2. filter symbolic links:

```bash title="/usr/bin/arm-linux-gnueabihf-*@" linenums="1"
$ ls -l /usr/bin | grep "\-> arm-linux-gnueabihf"
lrwxrwxrwx 1 root root          26  8月  5  2021 arm-linux-gnueabihf-cpp -> arm-linux-gnueabihf-cpp-11
lrwxrwxrwx 1 root root          26  8月  5  2021 arm-linux-gnueabihf-gcc -> arm-linux-gnueabihf-gcc-11
lrwxrwxrwx 1 root root          29  8月  5  2021 arm-linux-gnueabihf-gcc-ar -> arm-linux-gnueabihf-gcc-ar-11
lrwxrwxrwx 1 root root          29  8月  5  2021 arm-linux-gnueabihf-gcc-nm -> arm-linux-gnueabihf-gcc-nm-11
lrwxrwxrwx 1 root root          33  8月  5  2021 arm-linux-gnueabihf-gcc-ranlib -> arm-linux-gnueabihf-gcc-ranlib-11
lrwxrwxrwx 1 root root          27  8月  5  2021 arm-linux-gnueabihf-gcov -> arm-linux-gnueabihf-gcov-11
lrwxrwxrwx 1 root root          32  8月  5  2021 arm-linux-gnueabihf-gcov-dump -> arm-linux-gnueabihf-gcov-dump-11
lrwxrwxrwx 1 root root          32  8月  5  2021 arm-linux-gnueabihf-gcov-tool -> arm-linux-gnueabihf-gcov-tool-11
lrwxrwxrwx 1 root root          26  1月 23 23:08 arm-linux-gnueabihf-ld -> arm-linux-gnueabihf-ld.bfd
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

# previously installed gcc
pifan@rpi3b-ubuntu $ aarch64-linux-gnu-gcc --version
aarch64-linux-gnu-gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

As the well-known shims or wrappers like `cpp`,`gcc`,`g++`,`cc`,`c++`, has been taken over by previously installed `aarch64-linux-gnu-gcc`, you should always explicitly specify the prefix `arm-linux-gnueabihf-` when using them.

To cross-compile hello-world as a 32-bit Linux application. On Fedora, only building kernels is currently supported. Support for cross-building user space programs is not currently provided as that would massively multiply the number of packages.

```bash
$ arm-linux-gnueabihf-gcc hello-world-embedded.c -o hello-world.elf
```

To cross-compile hello-world as a 64-bit Linux application. On Fedora, only building kernels is currently supported. Support for cross-building user space programs is not currently provided as that would massively multiply the number of packages.

```bash
$ aarch64-linux-gnu-gcc hello-world-embedded.c -o hello-world.elf
```

## switch states

[Assembly challange - Raspberry Pi Forums](https://forums.raspberrypi.com/viewtopic.php?t=228003)

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 3.4 Changing between AArch64 and AArch32 states

The processor must be in the correct execution state for the instructions it is executing.

A processor that is executing A64 instructions is operating in AArch64 state. In this state, the instructions can access both the 64-bit and 32-bit registers.

A processor that is executing A32 or T32 instructions is operating in AArch32 state. In this state, the instructions can only access the 32-bit registers, and not the 64-bit registers.

A processor based on the Arm ® v8 architecture can run applications built for AArch32 and AArch64 states but a change between AArch32 and AArch64 states can only happen at exception boundaries.

Arm Compiler toolchain builds images for either the AArch32 state or AArch64 state. Therefore, an image built with Arm Compiler toolchain can either contain only A32 and T32 instructions or only A64 instructions.

A processor can *only* execute instructions from the instruction set that matches its *current* execution state. A processor in AArch32 state cannot execute A64 instructions, and a processor in AArch64 state cannot execute A32 or T32 instructions. You must ensure that the processor never receives instructions from the wrong instruction set for the current execution state.

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/a/An-Introduction-to-the-ARMv8-Instruction-Sets) | 5.3 Switching between the instruction sets

It is not possible to use code from the two execution states within a single application. There is no interworking between A64 and A32 or T32 instruction sets in ARMv8 as there is between A32 and T32 instruction sets. Code written in A64 for the ARMv8 processors cannot run on ARMv7 Cortex-A series processors. However, code written for ARMv7-A processors can run on ARMv8 processors in the AArch32 execution state. This is summarized in Figure 5-1.

<figure markdown="span">
    ![Figure 5.1. Switching between instruction sets](https://documentation-service.arm.com/static/5fbd26f271eff94ef49c7029)
    <figcaption>Figure 5.1. Switching between instruction sets</figcaption>
</figure>

## test demos

### asm

=== "adr-ldr-64.s"

    ```asm linenums="1"
        .text
        .align 2

        .equ    __STDOUT, 1

        // syscall NR defined in /usr/include/asm-generic/unistd.h
        // __ARM_ARCH_ISA_A64
        .equ    __NR_write, 64  // 0x40
        .equ    __NR_exit, 93   // 0x5d
        // .equ    __NR_write, 4
        // .equ    __NR_exit, 1

        .global _start

    _start:
        mov x0, #__STDOUT
        adr x1, msg
        ldr x2, len
        mov x8, #__NR_write
        svc #0

    _exit:
        mov x0, #0
        mov x8, #__NR_exit
        svc #0

    msg:
    //  __ARM_ARCH_ISA_A64
    .ascii "Hi A64!\n"
    // .ascii "Hi A32!\n"

    len:
    .word 8
    ```

    ```bash
    # aarch64-linux-gnu-as && aarch64-linux-gnu-ld
    $ as adr-ldr-64.s -o adr-ldr-64.o && ld adr-ldr-64.o -o adr-ldr-64

    $ file adr-ldr-64
    adr-ldr-64: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, not stripped

    $ objdump -f adr-ldr-64

    adr-ldr-64:     file format elf64-littleaarch64
    architecture: aarch64, flags 0x00000112:
    EXEC_P, HAS_SYMS, D_PAGED
    start address 0x0000000000400078

    $ ./adr-ldr-64
    Hi A64!
    ```

=== "adr-ldr-32.s"

    ```asm linenums="1"
        .text
        .align 2

        .equ    __STDOUT, 1
        // syscall NR defined in /usr/include/asm-generic/unistd.h
        //  __ARM_ARCH_ISA_A64
        // .equ    __NR_write, 64   // 0x40
        // .equ    __NR_exit, 93    // 0x5d
        .equ    __NR_write, 4
        .equ    __NR_exit, 1

        .global _start

    _start:
        mov r0, #__STDOUT
        adr r1, msg
        ldr r2, len
        mov r7, #__NR_write
        svc #0

    _exit:
        mov r0, #0
        mov r7, #__NR_exit
        svc #0

    msg:
    //  __ARM_ARCH_ISA_A64
    // .ascii "Hi A64!\n"
    .ascii "Hi A32!\n"

    len:
    .word 8
    ```

    ```bash
    $ arm-linux-gnueabihf-as adr-ldr-32.s -o adr-ldr-32.o && arm-linux-gnueabihf-ld adr-ldr-32.o -o adr-ldr-32

    $ file adr-ldr-32
    adr-ldr-32: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, not stripped

    $ objdump -f adr-ldr-32

    adr-ldr-32:     file format elf32-littlearm
    architecture: armv3m, flags 0x00000112:
    EXEC_P, HAS_SYMS, D_PAGED
    start address 0x00010054

    $ readelf -h adr-ldr-32 | grep Flags
      Flags:                             0x5000200, Version5 EABI, soft-float ABI

    $ ./adr-ldr-32
    Hi A32!
    ```

### c - qemu

```c title="write.c"
#include <unistd.h>

int main(int argc, char* argv[]) {
#if __ARM_ARCH_ISA_A64 // __ARM_64BIT_STATE
    write(1, "Hi A64!\n", 8);
#else // __ARM_ARCH_ISA_ARM // __ARM_32BIT_STATE
    write(1, "Hi A32!\n", 8);
#endif

    return 0;
}
```

rpi3b-ubuntu/aarch64 naturally run in AArch64 state.

```bash
$ aarch64-linux-gnu-gcc -x c -E -dM /dev/null | grep -E "__ARM_ARCH_ISA_|__ARM_(32|64)BIT_STATE"
#define __ARM_64BIT_STATE 1
#define __ARM_ARCH_ISA_A64 1

# aarch64-linux-gnu-gcc
$ gcc write.c -o write64 && ./write64
Hi A64!
```

To run ELF32(A32) under Aarch64(A64), we have to resort to QEMU emulator.
The emulator will interpret the ARM machine code and simulate it using the local processor.

[Blue Fox: Arm Assembly Internals and Reverse Engineering](https://www.amazon.com/Blue-Fox-Assembly-Internals-Analysis/dp/1119745306) | Chapter 9 Arm Environments - Emulation with QEMU

Let’s first install the following packages:

```bash
$ sudo apt install qemu-user qemu-user-static
```

For the Arm 32-bit, we need to run the compatible GCC version.
Let’s compile the program for AArch32 and run it on an AArch64 Linux host using QEMU’s user-mode emulation.

We can now cross-compile this program with the AArch32 version of GCC to create a static executable:

```bash
$ arm-linux-gnueabihf-gcc -x c -E -dM /dev/null | grep -E "__ARM_ARCH_ISA_|__ARM_(32|64)BIT_STATE"
#define __ARM_ARCH_ISA_ARM 1
#define __ARM_32BIT_STATE 1
#define __ARM_ARCH_ISA_THUMB 2

$ arm-linux-gnueabihf-gcc -static write.c -o swrite32

$ file swrite32
swrite32: ELF 32-bit LSB executable, ARM, EABI5 version 1 (GNU/Linux), statically linked, BuildID[sha1]=3befb9bf54c9686e132f66f3b261cf0e26c5c569, for GNU/Linux 3.2.0, not stripped

$ objdump -f swrite32

swrite32:     file format elf32-littlearm
architecture: armv7, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x00010339

$ readelf -h swrite32 | grep Flags
  Flags:                             0x5000400, Version5 EABI, hard-float ABI
```

We can now run this binary directly using QEMU’s *user-mode emulation*:

```bash
# or just ./swrite32
$ qemu-arm-static ./swrite32
Hi A32!
```

We can also run this binary directly from the command line without specifying `qemu-arm-static`.

For dynamically linked executables, we can supply the path of the ELF interpreter and libraries via the command line option `-L`.

```bash
$ arm-linux-gnueabihf-gcc write.c -o dwrite32

$ file dwrite32
dwrite32: ELF 32-bit LSB pie executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, BuildID[sha1]=1562e8ee664fa668df0743d4a77812400307b5d3, for GNU/Linux 3.2.0, not stripped

$ objdump -f dwrite32

dwrite32:     file format elf32-littlearm
architecture: armv7, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x00000409

$ ./dwrite32
zsh: no such file or directory: ./dwrite32

$ qemu-arm -L /usr/arm-linux-gnueabihf/ ./dwrite32
Hi A32!
```

## references

[radcolor/arm-linux-gnueabi](https://github.com/radcolor/arm-linux-gnueabi) / [radcolor/aarch64-linux-gnu](https://github.com/radcolor/aarch64-linux-gnu)

??? info "AArch32 in AArch64"

    [32 Bit executables in AARCH64 system - ODROID](https://forum.odroid.com/viewtopic.php?t=18806)
    [linux - Running 32-bit ARM binary on aarch64 not working despite CONFIG_COMPAT - Stack Overflow](https://stackoverflow.com/questions/59379848/running-32-bit-arm-binary-on-aarch64-not-working-despite-config-compat)
    [How to run 32-bit (armhf) binaries on 64-bit (arm64) Debian OS on Raspberry Pi? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/625576/how-to-run-32-bit-armhf-binaries-on-64-bit-arm64-debian-os-on-raspberry-pi)

    [What is the difference between arm-linux-gcc and arm-none-linux-gnueabi - Stack Overflow](https://stackoverflow.com/questions/13797693/what-is-the-difference-between-arm-linux-gcc-and-arm-none-linux-gnueabi)
    [20.04 - How to install "gcc-arm-linux-gnueabihf" specific version? - Ask Ubuntu](https://askubuntu.com/questions/1448687/how-to-install-gcc-arm-linux-gnueabihf-specific-version)

    [交叉编译工具 gcc-aarch64-linux-gnu 的介绍与安装](https://blog.csdn.net/song_lee/article/details/105487177)
    [linux安装交叉编译器gcc-arm-linux-gnueabi](https://blog.csdn.net/qq_39397165/article/details/103252179)

??? info "QEMU User space emulator"

    [QEMU documentation](https://www.qemu.org/docs/master/user/main.html)
    [QemuUserEmulation - Debian Wiki](https://wiki.debian.org/QemuUserEmulation)

    [Emulating ARM on Debian/Ubuntu](https://gist.github.com/bruce30262/e0f12eddea638efe7332)
    [Emulating ARM with QEMU on Debian/Ubuntu](https://gist.github.com/luk6xff/9f8d2520530a823944355e59343eadc1)

    [qemu-user-static/docs/developers_guide.md](https://github.com/multiarch/qemu-user-static/blob/master/docs/developers_guide.md)
    [基于QEMU和binfmt-misc透明运行不同架构程序](https://blog.lyle.ac.cn/2020/04/14/transparently-running-binaries-from-any-architecture-in-linux-with-qemu-and-binfmt-misc/)
    [linux下使用binfmt_misc设定不同二进制的打开程序](https://blog.csdn.net/whatday/article/details/88299482)

    [qemu - What's the difference between "arm-linux-user" and "armeb-linux-user"? - Stack Overflow](https://stackoverflow.com/questions/44454063/whats-the-difference-between-arm-linux-user-and-armeb-linux-user)
    [linux - what is default qemu arm enviroment in qemu-arm-static? - Stack Overflow](https://stackoverflow.com/questions/53809816/what-is-default-qemu-arm-enviroment-in-qemu-arm-static)
    [What is binfmt_misc and how to enable/disable it ? - Red Hat Customer Portal](https://access.redhat.com/solutions/1985633)
    [Install binfmt for all cpus via qemu-user-static](https://gist.github.com/DmitryOlshansky/b5b193d83633e08f29def63e32e9691e)
