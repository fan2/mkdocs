---
title: Compiler Toolchain
authors:
  - xman
date:
    created: 2009-10-03T10:00:00
    updated: 2024-04-01T10:00:00
categories:
    - toolchain
comments: true
---

Concepts of Cross compiler and Toolchain.

<!-- more -->

## Toolchain

[Toolchain](https://en.wikipedia.org/wiki/Toolchain)

In software, a toolchain is a set of [programming tools](https://en.wikipedia.org/wiki/Programming_tool) that are used to perform a complex software development task or to create a software product, which is typically another computer program or a set of related programs. In general, the tools forming a toolchain are executed consecutively so the output or resulting environment state of each tool becomes the input or starting environment for the next one, but the term is also used when referring to a set of related tools that are not necessarily executed consecutively.

A simple software development toolchain often refers to the necessary tools to develop for a given operating system running a certain CPU architecture, consisting of a [compiler](https://en.wikipedia.org/wiki/Compiler) and [linker](https://en.wikipedia.org/wiki/Linker_(computing)) (which transform the source code into an [executable program](https://en.wikipedia.org/wiki/Executable_program)), [libraries](https://en.wikipedia.org/wiki/Software_library) (which provide interfaces to the operating system), and a [debugger](https://en.wikipedia.org/wiki/Debugger) (which is used to test and debug created programs). Cross-compilation toolchains are also available. A complex software product such as a video game needs tools for preparing sound effects, music, textures, 3-dimensional models and animations, together with additional tools for combining these resources into the finished product.

[What exactly is a compiler tool chain?](https://www.quora.com/What-exactly-is-a-compiler-tool-chain)

!!! quote "Ajinkya RC"

    Every program of any language is written in a high level language. This must be converted to machine understandable language. So, *Compiler* is the predefined set of program that does this activity. Also, there are number of different components that play important role. This whole set of components is nothing but the Compiler tool chain.

    Lets consider the simple C program: When we write a normal program `hello.c` and compile it, **compiler** *converts* it into a machine code. It creates a `hello.obj` file but its not executable at this stage.

    After this, **Linker** comes into the picture. It *links* some additional code with that `.obj` file. Linker also gives a magic number with this code and this process is called as 'Primary Header'. It also *links* static and dynamic library functions to this code. This additional code helps the `.obj` file to be executable.

    Now, **Loader** does the further work. Loader *splits* the code in S, T & D sections. These sections are present on the RAM. Stack contains all the functions in the code. Text section contains the information of the functions and others texts present in the program and Data section contains all the data.

    Thus the execution of the code takes place when the program goes from Hard Disk to RAM.

    Here the compiler tool chain contains three basic elements, first compiler itself, second Linker and third Loader.

## Cross compiler

[Cross compiler](https://en.wikipedia.org/wiki/Cross_compiler)

A cross compiler is a compiler capable of creating executable code for a platform other than the one on which the compiler is running. For example, a compiler that runs on a PC but generates code that runs on Android devices is a cross compiler.

A cross compiler is useful to compile code for multiple platforms from one development host. Direct compilation on the target platform might be infeasible, for example on embedded systems with limited computing resources.

Cross compilers are distinct from source-to-source compilers. A cross compiler is for cross-platform software generation of machine code, while a source-to-source compiler translates from one coding language to another in text code. Both are [programming tools](https://en.wikipedia.org/wiki/Programming_tool).

## eLinux Toolchains

[Toolchains - eLinux.org](http://www.elinux.org/Toolchains)

A toolchain is a set of distinct software development tools that are linked (or chained) together by specific stages such as `GCC`, `binutils` and `glibc` (a portion of the GNU Toolchain). Optionally, a toolchain may contain other tools such as a [debugger](http://en.wikipedia.org/wiki/Debugger) or a [compiler](http://en.wikipedia.org/wiki/Compiler) for a specific programming language, such as C++. Quite often, the toolchain used for embedded development is a cross toolchain, or more commonly known as a [cross compiler](http://en.wikipedia.org/wiki/Cross_compiler). All the programs (like GCC) run on a host system of a specific architecture (such as x86), but they produce binary code (executables) to run on a *different* architecture (for example, ARM). This is called cross compilation and is the typical way of building embedded software. It is possible to compile natively, running GCC on your target. Before searching for a prebuilt toolchain or building your own, it's worth checking to see if one is included with your target hardware's Board Support Package ([BSP](http://en.wikipedia.org/wiki/Board_support_package)) if you have one.

When talking about toolchains, one must distinguish *three* different machines:

- the `build` machine, on which the toolchain is built  
- the `host` machine, on which the toolchain is executed  
- the `target` machine, for which the toolchain generates code  

From these three different machines, we distinguish *four* different types of toolchain building processes :

- A native toolchain, as can be found in normal Linux distributions, has usually been compiled on x86, runs on x86 and generates code for x86.
- A cross-compilation toolchain, which is the most interesting toolchain type for embedded development, is typically compiled on x86, runs on x86 and generates code for the target architecture (be it ARM, MIPS, PowerPC or any other architecture supported by the different toolchain components)
- A cross-native toolchain, is a toolchain that has been built on x86, but runs on your target architecture and generates code for your target architecture. It's typically needed when you want a native GCC on your target platform, without building it on your target platform.
- A Canadian build is the process of building a toolchain on machine A, so that it runs on machine B and generates code for machine C. It's usually not really necessary.

## cross compiler toolchain

[What is cross compile and toolchain?](http://www.xuebuyuan.com/508805.html)

[What is a toolchain and a cross compiler?](https://stackoverflow.com/questions/22756199/what-is-a-toolchain-and-a-cross-compiler)

!!! quote "Mats Petersson"

    If we define the word `host` to mean a computer on which you are compiling, and `target` as the computer on which you want to run the code, then a **native** compiler is one where the target and the host are the *same* (kind). A **cross**-compiler is a compiler where the target is *different* from the host.

    A toolchain is the set of `compiler + linker + librarian + any other tools` you need to produce the executable (+ shared libraries, etc) for the target. A debugger and/or IDE may also count as part of a toolchain.

    [What exactly is a compiler tool chain?](https://www.quora.com/What-exactly-is-a-compiler-tool-chain)

[What exactly is a compiler tool chain?](https://www.quora.com/What-exactly-is-a-compiler-tool-chain)

!!! quote "Greg Kemnitz"

    The notion of a [Toolchain](https://en.wikipedia.org/wiki/Toolchain) is usually used in the embedded world. It is the **package** of software needed to compile, link, and deploy software from a development `host` to the `target` device. (In most embedded devices, the device itself doesn't have enough capability to support development directly on the device.)

    A toolchain will have some sort of [Cross compiler](https://en.wikipedia.org/wiki/Cross_compiler) and linker for the target, possibly a [Debugger](https://en.wikipedia.org/wiki/Debugger) (which may allow on-device debugging), occasionally some sort of [simulator](https://en.wikipedia.org/wiki/Computer_architecture_simulator) that allows testing and debugging on the development host, a mechanism for deploying to the device, etc.

    Sometimes the toolchain may involve a full IDE (like Microsoft VC++ Embedded or Hitachi's IDEs), often it is a **collection** of *command-line tools*, especially if the toolchain is hosted on Unix/Linux.

## refs

[Arm GNU Toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain)

[RISC-V GNU Compiler Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)

- [WinLibs - GCC+MinGW-w64 compiler for Windows](https://winlibs.com/)
- [x86_64-linux-gnu-gcc(1) - Linux man page](https://linux.die.net/man/1/x86_64-linux-gnu-gcc)
- [arm-linux-gnu-gcc(1) - Linux man page](https://linux.die.net/man/1/arm-linux-gnu-gcc)
- [aarch64-linux-gnu-gcc(1) - Linux man page](https://linux.die.net/man/1/aarch64-linux-gnu-gcc)

[Buildroot - Making Embedded Linux Easy](https://buildroot.org/) - [wiki](https://en.wikipedia.org/wiki/Buildroot)

[Cross Compiling With CMake — Mastering CMake](https://cmake.org/cmake/help/book/mastering-cmake/chapter/Cross%20Compiling%20With%20CMake.html)

[GN](https://gn.googlesource.com/gn/) is a meta-build system that generates build files for [Ninja](https://ninja-build.org/) @[github](https://github.com/ninja-build/ninja).

- [The Ninja build system](https://ninja-build.org/manual.html)

[crosstool-ng](https://github.com/crosstool-ng/crosstool-ng): A versatile (cross-)toolchain generator.

- [Documentation](https://crosstool-ng.github.io/docs/) - [How a toolchain is constructed](https://crosstool-ng.github.io/docs/toolchain-construction/)