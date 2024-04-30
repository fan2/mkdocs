---
title: Mainstream Compiler - gcc/clang/msvc
authors:
  - xman
date:
    created: 2020-02-02T10:00:00
    updated: 2024-04-02T10:00:00
categories:
    - toolchain
comments: true
---

Try and tease out mainstream compilers(GNU/GCC, LLVM/Clang, Microsoft Visual Studio) architecture/framework, toolchain, binutils and language(C/C++) standards.

<!-- more -->

## GNU/GCC

[The GNU Operating System and the Free Software Movement](https://www.gnu.org/)

!!! abstract "What is GNU?"

    GNU is an operating system that is [free software](https://www.gnu.org/philosophy/free-sw.html)—that is, it respects users' freedom. The GNU operating system consists of GNU packages (programs specifically released by the GNU Project) as well as free software released by third parties. The development of GNU made it possible to use a computer without software that would trample your freedom.

    We recommend installable versions of GNU (more precisely, [GNU/Linux](https://www.gnu.org/gnu/linux-and-gnu.html) distributions) which are entirely free software.

[GCC, the GNU Compiler Collection](https://gcc.gnu.org/)

!!! abstract "What is GCC?"

    The GNU Compiler Collection includes front ends for [](https://gcc.gnu.org/c99status.html), [C++](https://gcc.gnu.org/projects/cxx-status.html), Objective-C, Fortran, Ada, Go, and D, as well as libraries for these languages (libstdc++,...). GCC was originally written as the compiler for the [GNU operating system](http://www.gnu.org/gnu/thegnuproject.html). The GNU system was developed to be 100% free software, free in the sense that it respects the user's freedom.

    We strive to provide regular, high quality [releases](https://gcc.gnu.org/releases.html), which we want to work well on a variety of native and cross targets (including GNU/Linux), and encourage everyone to contribute changes or help testing GCC.

[GCC, the GNU Compiler Collection](https://gcc.gnu.org/) @[git](git://gcc.gnu.org/git/gcc.git) - [wiki](https://en.wikipedia.org/wiki/GNU_Compiler_Collection)

[GCC online documentation](https://gcc.gnu.org/onlinedocs/)

- [Option Summary](https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html)
- [Overall Options](https://gcc.gnu.org/onlinedocs/gcc/Overall-Options.html)

### Architecture

[GNU C Compiler Internals/Architecture](https://en.wikibooks.org/wiki/GNU_C_Compiler_Internals/GNU_C_Compiler_Architecture)

For a C source file they are the preprocessor and compiler `cc1`, the assembler `as`, and the linker `collect2`. The first and the third programs come with a GCC *distribution*, the assembler is a part of the GNU *binutils* package.

![GCC_Architecture](./images/GCC_Architecture.jpeg)

[Developer Options](https://gcc.gnu.org/onlinedocs/gcc/Developer-Options.html): `-dumpspecs` : Print the compiler’s built-in [Spec Files](https://gcc.gnu.org/onlinedocs/gcc/Spec-Files.html):

- cpp : Options to pass to the C preprocessor
- cc1 : Options to pass to the C compiler
- cc1plus : Options to pass to the C++ compiler

[cpp - The C Preprocessor](https://gcc.gnu.org/onlinedocs/cpp/)

- [Invocation](https://gcc.gnu.org/onlinedocs/cpp/Invocation.html): the preprocessor is actually *integrated* with the compiler rather than a separate program.
- [Preprocessor Options](https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html): `-no-integrated-cpp`: Perform preprocessing as a *separate* pass before compilation.

[FAQ - GCC Wiki](https://gcc.gnu.org/wiki/FAQ#include_search_path): the GCC C compiler (`cc1`) and C++ compiler (`cc1cplus`)

[Why cc1 is called cc1?](https://stackoverflow.com/questions/13753854/why-cc1-is-called-cc1) [Relationship between cc1 and gcc?](https://unix.stackexchange.com/questions/77779/relationship-between-cc1-and-gcc)

> The 1 in `cc1` indicates that it is the first stage of the build process. The second stage is `collect2`.

[Collect2 (GCC Internals)](https://gcc.gnu.org/onlinedocs/gccint/Collect2.html): The program `collect2` is installed as `ld` in the directory where the passes of the compiler are installed.

### gcc and g++

GNU C Compiler: `gcc` / `cc`

- `c89` - ANSI (1989) C compiler
- `c99` - ANSI (1999) C compiler

GNU C++ Compiler: `g++` / `c++`

[Invoking G++ - Compiling C++ Programs](https://gcc.gnu.org/onlinedocs/gcc/Invoking-G_002b_002b.html)

GCC recognizes C++ header/source files with these names and compiles them as C++ programs even if you call the compiler the same way as for compiling C programs (usually with the name `gcc`).

However, the use of `gcc` does not add the C++ library. `g++` is a program that calls GCC and automatically specifies *linking* against the C++ library. It treats ‘.c’, ‘.h’ and ‘.i’ files as C++ source files instead of C source files unless `-x` is used. This program is also useful when precompiling a C header file with a ‘.h’ extension for use in C++ compilations. On many systems, `g++` is also installed with the name `c++`.

[What is the difference between g++ and gcc?](https://stackoverflow.com/questions/172587/what-is-the-difference-between-g-and-gcc)

`g++` is roughly equivalent to `gcc -xc++ -lstdc++ -shared-libgcc` (the 1st is a compiler option, the 2nd two are linker options).

- `-xc++`: Specify explicitly the language
- `-lstdc++`: Search the library named `stdc++`(libstdc++) when linking
- `-shared-libgcc`: G++ driver automatically adds this to use exceptions for C++ programs

[Difference between GCC and G++](https://www.geeksforgeeks.org/difference-between-gcc-and-g/)

g++ | gcc
----|-----
g++ is used to compile C++ program. | gcc is used to compile C program.
g++ can compile any .c or .cpp files but they will be treated as C++ files only. | gcc can compile any .c or .cpp files but they will be treated as C and C++ respectively.
Command to compile C++ program through g++ is `g++ fileName.cpp -o binary` | command to compile C program through gcc is `gcc fileName.c -o binary`
Using g++ to link the object files, files automatically links in the std C++ libraries. | gcc does not do this.
g++ compiles with more predefined macros. | gcc compiles C++ files with more number of predefined macros. Some of them are `#define __GXX_WEAK__ 1`, `#define __cplusplus 1`, `#define __DEPRECATED 1`, etc

下面是 rpi4b-ubuntu 的 /usr/bin 下 `cpp`、`gcc`、`g++` 命令，真身分别为 aarch64-linux-gnu-cpp-11、aarch64-linux-gnu-gcc-11、aarch64-linux-gnu-g++-11。

- aarch64-linux-gnu-gcc-11、aarch64-linux-gnu-g++-11 这两个二进制文件 size 一样，但是 md5sum 不一致。

```Shell
$ ls -l /usr/bin | grep -E "cpp|cc|[g|c]\+\+"
-rwxr-xr-x 1 root root         428 Nov 18  2020 c89-gcc
-rwxr-xr-x 1 root root         454 Nov 18  2020 c99-gcc

-rwxr-xr-x 1 root root      876656 May 13  2023 aarch64-linux-gnu-cpp-11
lrwxrwxrwx 1 root root          24 May 13  2023 cpp-11 -> aarch64-linux-gnu-cpp-11
lrwxrwxrwx 1 root root           6 Aug  5  2021 aarch64-linux-gnu-cpp -> cpp-11
lrwxrwxrwx 1 root root           6 Aug  5  2021 cpp -> cpp-11

-rwxr-xr-x 1 root root      872560 May 13  2023 aarch64-linux-gnu-gcc-11
lrwxrwxrwx 1 root root          24 May 13  2023 gcc-11 -> aarch64-linux-gnu-gcc-11
lrwxrwxrwx 1 root root           6 Aug  5  2021 aarch64-linux-gnu-gcc -> gcc-11
lrwxrwxrwx 1 root root           6 Aug  5  2021 gcc -> gcc-11

-rwxr-xr-x 1 root root      872560 May 13  2023 aarch64-linux-gnu-g++-11
lrwxrwxrwx 1 root root          24 May 13  2023 g++-11 -> aarch64-linux-gnu-g++-11
lrwxrwxrwx 1 root root           6 Aug  5  2021 aarch64-linux-gnu-g++ -> g++-11
lrwxrwxrwx 1 root root           6 Aug  5  2021 g++ -> g++-11

lrwxrwxrwx 1 root root          20 Feb 21 10:59 cc -> /etc/alternatives/cc
lrwxrwxrwx 1 root root          21 Feb 21 10:59 c++ -> /etc/alternatives/c++
```

进一步验证，`cc`、`c++` 分别是 gcc、g++ 的软链。

```Shell
$ ls -l /etc/alternatives/cc
lrwxrwxrwx 1 root root 12 Feb 21 10:59 /etc/alternatives/cc -> /usr/bin/gcc

$ ls -l /etc/alternatives/c++
lrwxrwxrwx 1 root root 12 Feb 21 10:59 /etc/alternatives/c++ -> /usr/bin/g++
```

### GNU binutils

[GNU Hurd / GNU Binutils](https://www.gnu.org/savannah-checkouts/gnu/hurd/binutils.html) - [GNU Binutils](https://www.gnu.org/software/binutils/)

Computer Systems - A Programmer’s Perspective | Chapter 7: Linking - 7.14 Tools for Manipulating Object Files:

> There are a number of tools available on Linux systems to help you understand and manipulate object ﬁles. In particular, the GNU *binutils* package is especially helpful and runs on every Linux platform.

The GNU Binutils are a collection of binary tools. The main ones are:

- `ld` - the GNU linker.
- `as` - the GNU assembler.
- `gold` - a new, faster, ELF only linker.

But they also include:

- `addr2line` - Converts addresses into filenames and line numbers.
- `ar` - A utility for creating, modifying and extracting from archives.
- `c++filt` - Filter to demangle encoded C++ symbols.
- `dlltool` - Creates files for building and using DLLs.
- `elfedit` - Allows alteration of ELF format files.
- `nm` - Lists symbols from object files.
- `objcopy` - Copies and translates object files.
- `objdump` - Displays information from object files.

    - The mother of all binary tools.
    - Can display *all* of the information in an object ﬁle. 
    - Its most useful function is *disassembling* the binary instructions in the `.text` section.

- `ranlib` - Generates an index to the contents of an archive.
- `readelf` - Displays information from any ELF format object file.
    - Subsumes the functionality of `size` and `nm`.
- `size` - Lists the section sizes of an object or archive file.
- `strip` - Discards symbols.

Linux systems also provide the ldd program for manipulating shared libraries:

- `ldd` - print shared object dependencies. Lists the shared libraries that an executable needs at run time.

在 Linux(Ubuntu) 下，这些 GNU Binutils 一般预装在 `/usr/bin/` 目录下。

### Language Standards

[Language Standards Supported by GCC](https://gcc.gnu.org/onlinedocs/gcc/Standards.html)

[Options Controlling the Kind of Output](https://gcc.gnu.org/onlinedocs/gcc/Overall-Options.html)

```Shell
-x language
Specify explicitly the language for the following input files (rather than letting the compiler choose a default based on the file name suffix). This option applies to all following input files until the next -x option.
```

[Options Controlling C Dialect](https://gcc.gnu.org/onlinedocs/gcc/C-Dialect-Options.html)

```Shell
-ansi
In C mode, this is equivalent to -std=c90. In C++ mode, it is equivalent to -std=c++98.

-std=
Determine the language standard. See Language Standards Supported by GCC, for details of these standard versions. This option is currently only supported when compiling C or C++.
```

[Options Controlling C++ Dialect](https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Dialect-Options.html)

```Shell
-stdlib=libstdc++,libc++
When G++ is configured to support this option, it allows specification of alternate C++ runtime libraries. Two options are available: libstdc++ (the default, native C++ runtime for G++) and libc++ which is the C++ runtime installed on some operating systems (e.g. Darwin versions from Darwin11 onwards). The option switches G++ to use the headers from the specified library and to emit -lstdc++ or -lc++ respectively, when a C++ runtime is required for linking.
```

!!! question "c++11/gnu++11 有什么区别？"

    -std=`c++11`: The 2011 ISO C++ standard plus amendments.
    -std=`gnu++11`: GNU dialect of -std=c++11. ISO C 2011 with GNU extensions.

    [What are the differences between -std=c++11 and -std=gnu++11?](https://stackoverflow.com/questions/10613126/what-are-the-differences-between-std-c11-and-std-gnu11)  

    the difference between the two options is whether GNU extensions that violates the C++ standard are **enabled** or not. The GNU extensions are described [here](https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Extensions.html).

使用 gcc 编译链接的时候，默认是采用动态链接的方式。如果要指定静态链接，有两种方式：

1. 使用 `-static` 选项，开启全静态链接。
2. 使用 `-Wl,-Bstatic`，`-Wl,-Bdynamic` 选项，将部分动态库设置为静态链接。

参考 [gcc 全静态链接](https://www.cnblogs.com/motadou/p/4471088.html)，[Q: linker "-static" flag usage](https://gcc.gnu.org/legacy-ml/gcc/2000-05/msg00517.html) 和 GCC [Link Options](https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html) 中的相关选项说明。

- -static
- -static-libgcc
- -static-libstdc++

一些抑制/定制默认链接的选项：

```Shell
-nostartfiles
Do not use the standard system startup files when linking.

-nodefaultlibs
Do not use the standard system libraries when linking.

-nolibc
Do not use the C library or system libraries tightly coupled with it when linking.

-nostdlib
Do not use the standard system startup files or libraries when linking.

-nostdlib++
Do not implicitly link with standard C++ libraries.
```

#### glibc

[The GNU C Library](https://www.gnu.org/software/libc/) - [wiki](https://en.wikipedia.org/wiki/Glibc)

- [Documentation for the GNU C Library](https://sourceware.org/glibc/manual/)
- [The GNU C Reference Manual](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html)

GNU C sourceware:

- @[sourceware](https://sourceware.org/glibc/), [git](git://sourceware.org/git/glibc.git)
- [Index of /gnu/libc](https://ftp.gnu.org/gnu/libc/)

[Linux的libc库](https://blog.csdn.net/Erice_s/article/details/106184779)，[libc、glibc 和 glib 的关系](https://blog.csdn.net/yasi_xi/article/details/9899599)
[What is the role of libc(glibc) in our linux app?](https://stackoverflow.com/questions/11372872/what-is-the-role-of-libcglibc-in-our-linux-app)
[Is the development of libc tied with Linux?](https://www.quora.com/Is-the-development-of-libc-tied-with-Linux-I-mean-is-libc-Linux-specific-I-thought-that-libc-is-a-standard-that-is-OS-independent-but-I-am-not-sure-Is-libc-updated-anytime-Linux-changes-its-syscalls)

> There is GNU Libc and the C standard library. The former is an implementation of the latter, but there are many other implementations. Even on Linux glibc is not the only option.

Linux/ubuntu 下可执行 `man libc` 或 `info libc` 查看 [libc(7) - Linux manual page](https://man7.org/linux/man-pages/man7/libc.7.html)。

- [Ubuntu Manpage: libc - overview of standard C libraries on Linux](https://manpages.ubuntu.com/manpages/bionic/man7/libc.7.html)

!!! note "libc vs. glibc"

    The term `libc` is commonly used as a shorthand for the “standard C library”.

    By far the most widely used C library on Linux is the GNU C Library, often referred to as `glibc`.

    In the early to mid 1990s, there was for a while *Linux libc*, a fork of glibc 1.x created by Linux developers who felt that glibc development at the time was not sufficing for the needs of Linux. Often, this library was referred to (ambiguously) as just `libc`.

    However, notwithstanding the original motivations of the Linux libc effort, by the time glibc 2.0 was released (in 1997), it was clearly superior to Linux libc, and all major Linux distributions that had been using Linux libc soon **switched** back to `glibc`.

??? info "获取查看 glibc 版本号"

    [glibc 查看版本号](https://www.cnblogs.com/motadou/p/4473966.html), [Linux(Ubuntu/CentOS) 下查看 GLIBC 版本](https://blog.csdn.net/gatieme/article/details/108945425)

    通过 `getconf` 命令获取 GNU_LIBC_VERSION：

    ```Shell
    $ getconf GNU_LIBC_VERSION
    glibc 2.35
    ```

    `ldd` 是 glibc 提供的命令，执行 `ldd --version` 会输出 glibc 的版本号：

    ```Shell
    $ ldd --version
    ldd (Ubuntu GLIBC 2.35-0ubuntu3.7) 2.35
    Copyright (C) 2022 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    Written by Roland McGrath and Ulrich Drepper.
    ```

    直接执行 libc.so，可以看到 GLIBC 版本为 2.35：

    ```Shell
    $ /lib/aarch64-linux-gnu/libc.so.6
    GNU C Library (Ubuntu GLIBC 2.35-0ubuntu3.7) stable release version 2.35.
    Copyright (C) 2022 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.
    There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
    PARTICULAR PURPOSE.
    Compiled by GNU CC version 11.4.0.
    libc ABIs: UNIQUE ABSOLUTE
    For bug reporting instructions, please see:
    <https://bugs.launchpad.net/ubuntu/+source/glibc/+bugs>.
    ```

#### libstdc++

[The GNU C++ Library](https://gcc.gnu.org/onlinedocs/libstdc++/)

[The GNU C++ Library Manual](https://gcc.gnu.org/onlinedocs/libstdc++/manual/index.html)

The GCC project includes an implementation of the C++ Standard Library called `libstdc++`, licensed under the GPLv3 License with an exception to link non-GPL applications when sources are built with GCC.

[厘清 gcc、glibc、libstdc++ 的关系](https://www.jianshu.com/p/a3c983edabd1)

[如何升级linux的libstdc++.so - 知乎](https://zhuanlan.zhihu.com/p/498529973)

### GDB

[GCC Debugging Options](https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html)

[GNU Hurd / GNU GDB](https://www.gnu.org/savannah-checkouts/gnu/hurd/gdb.html) - [wiki](https://en.wikipedia.org/wiki/GNU_Debugger)

- [docs](https://sourceware.org/gdb/download/onlinedocs/): [Debugging with GDB](https://sourceware.org/gdb/download/onlinedocs/gdb.html/index.html)
- @[sourceware](https://www.sourceware.org/gdb/), [git](git://sourceware.org/git/binutils-gdb.git)

VisualGDB - [GDB Command Reference](https://visualgdb.com/gdbreference/commands/)
用GDB调试程序：[（一）](https://haoel.blog.csdn.net/article/details/2879) ～ [（七）](https://haoel.blog.csdn.net/article/details/2885)

[GDB online Debugger](https://www.onlinegdb.com/)

## LLVM/Clang

In 2006, [Chris Lattner](https://nondot.org/sabre/) started working on a new project named Clang. The combination of Clang *frontend* and LLVM *backend* is named Clang/LLVM or simply Clang.

[The LLVM Compiler Infrastructure Project](https://llvm.org/) - [wiki](https://en.wikipedia.org/wiki/LLVM) @[github](https://github.com/llvm/llvm-project)

- [LLVM's Documentation](https://llvm.org/docs/)

[Clang C Language Family Frontend for LLVM](https://clang.llvm.org/) - [wiki](https://en.wikipedia.org/wiki/Clang)

- [Clang's documentation](https://clang.llvm.org/docs/)
- [Clang Compiler User’s Manual](https://clang.llvm.org/docs/UsersManual.html)
- [clang - the Clang C, C++, and Objective-C compiler](https://clang.llvm.org/docs/CommandGuide/clang.html)
- [Clang command line argument reference](https://clang.llvm.org/docs/ClangCommandLineReference.html)
- [Preprocessor options](https://clang.llvm.org/docs/ClangCommandLineReference.html#preprocessor-options)

### Architecture

[Introduction to the LLVM Compiler System](https://llvm.org/pubs/2008-10-04-ACAT-LLVM-Intro.html)

[The Architecture of Open Source Applications (Volume 1) LLVM](https://aosabook.org/en/v1/llvm.html)

Three Major Components of a Three-Phase Compiler:

![Classical-Three-Phase-Compiler](https://aosabook.org/static/llvm/SimpleCompiler.png)

![Compiler_design-Three-stage-compiler-structure](./images/Compiler_design-Three-stage-compiler-structure.png)

Implications of this Design - Retargetablity:

![Retargetablity](https://aosabook.org/static/llvm/RetargetableCompiler.png)

LLVM's Implementation of Three-Phase Design:

![LLVM's Implementation of the Three-Phase Design](https://aosabook.org/static/llvm/LLVMCompiler1.png)

!!! abstract "LLVM Linker"

    The `lld` subproject is an attempt to develop a built-in, platform-independent linker for LLVM. lld aims to remove dependence on a third-party linker. As of May 2017, lld supports [ELF](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format), [PE/COFF](https://en.wikipedia.org/wiki/PE/COFF), [Mach-O](https://en.wikipedia.org/wiki/Mach-O), and [WebAssembly](https://en.wikipedia.org/wiki/WebAssembly) in descending order of completeness. lld is faster than both flavors of GNU ld.

    Unlike the GNU linkers, lld has built-in support for [link-time optimization](https://en.wikipedia.org/wiki/Link-time_optimization) (LTO). This allows for faster code generation as it bypasses the use of a linker plugin, but on the other hand prohibits interoperability with other flavors of LTO.

### GCC compatibility

[Clang Performance and GCC compatibility](https://en.wikipedia.org/wiki/Clang#Performance_and_GCC_compatibility)

> Clang Compiler Driver (Drop-in Substitute for GCC): The clang tool is the compiler driver and front-end, which is designed to be a drop-in replacement for the gcc command.

!!! abstract "GCC compatibility"

    Clang is compatible with GCC. Its command-line interface shares many of GCC's flags and options. Clang implements many GNU language extensions and compiler intrinsics, some of which are purely for compatibility. For example, even though Clang implements atomic intrinsics which correspond exactly with C11 atomics, it also implements GCC's __sync_* intrinsics for compatibility with GCC and libstdc++. Clang also maintains ABI compatibility with GCC-generated object code. In practice, Clang is a drop-in replacement for GCC.

[gcc - Is there a binutils for llvm? - Stack Overflow](https://stackoverflow.com/questions/5238582/is-there-a-binutils-for-llvm)

### llvm-gcc/llvm-g++

```Shell
$ which clang
/usr/bin/clang

# /usr/bin/clang --version
$ clang --version
Apple clang version 15.0.0 (clang-1500.3.9.4)
Target: arm64-apple-darwin23.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

# clang++ 是 clang 的替身软链（symbolic link）
$ ls -l /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin | grep g++
lrwxr-xr-x  1 root  wheel          5 Mar  6 13:04 clang++ -> clang
```

在 macOS 中，gcc 以某种方式指向 `llvm-gcc` 编译器。`llvm-gcc` 是 c/c++/oc 的编译器，用了 gcc 前端和命令行界面的 llvm。

> llvm-gcc is a C, C++, Objective-C and Objective-C++ compiler.
> llvm-gcc uses gcc front-end and gcc's command line interface.
> In Apple's version of GCC, both cc and gcc are actually *symbolic links* to the llvm-gcc compiler.

g++ 则以某种方式指向 `llvm-g++` 编译器。

> llvm-g++ is a compiler driver for C++.
> Similarly, c++ and g++ are links to llvm-g++.

由 `gcc --version` 和 `g++ --version` 输出的 InstalledDir 可以看出，gcc/g++ 实际上是 XcodeDefault.xctoolchain 下 clang/clang++ 的 [shims or wrapper](http://stackoverflow.com/questions/9329243/xcode-4-4-and-later-install-command-line-tools/) executables。

```Shell
$ xcrun -f gcc
/Applications/Xcode.app/Contents/Developer/usr/bin/gcc
$ gcc --version
Apple clang version 15.0.0 (clang-1500.3.9.4)
Target: arm64-apple-darwin23.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

$ xcrun -f g++
/Applications/Xcode.app/Contents/Developer/usr/bin/g++
$ g++ --version
Apple clang version 15.0.0 (clang-1500.3.9.4)
Target: arm64-apple-darwin23.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

$ xcrun -f cc
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc
$ xcrun -f c++
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++
$ xcrun -f cpp
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cpp
```

macOS 下 llvm/clang 的 compiler toolchain Binutils 散落在四个 */usr/bin 目录下：

1. /usr/bin
2. /Library/Developer/CommandLineTools/usr/bin
3. /Applications/Xcode.app/Contents/Developer/usr/bin
4. /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

对四个 */usr/bin 目录分支执行 `ls -l` 过滤出 clang, cc/gcc, g++/c++ 相关命令。

```Shell
usrbin=/usr/bin
cmdbin=/Library/Developer/CommandLineTools/usr/bin
xcdevpath=`xcode-select -p` # /Applications/Xcode.app/Contents/Developer
xcdevbin=$xcdevpath/usr/bin
xctcbin=$xcdevpath/Toolchains/XcodeDefault.xctoolchain/usr/bin

ls -l $usrbin | grep -E "clang|(cc|gcc)$|[g|c]\+\+"
ls -l $cmdbin | grep -E "clang|(cc|gcc)$|[g|c]\+\+"
ls -l $xcdevbin | grep -E "clang|(cc|gcc)$|[g|c]\+\+"
ls -l $xctcbin | grep -E "clang|(cc|gcc)$|[g|c]\+\+"
```

=== "usrbin"

    ```Shell
    $ ls -l $usrbin | grep -E "clang|cpp|(cc|gcc)$|[g|c]\+\+"
    -rwxr-xr-x  77 root   wheel    119008 Apr 20 12:52 c++
    -rwxr-xr-x  77 root   wheel    119008 Apr 20 12:52 cc
    -rwxr-xr-x  77 root   wheel    119008 Apr 20 12:52 clang
    -rwxr-xr-x  77 root   wheel    119008 Apr 20 12:52 clang++
    -rwxr-xr-x  77 root   wheel    119008 Apr 20 12:52 cpp
    -rwxr-xr-x  77 root   wheel    119008 Apr 20 12:52 g++
    -rwxr-xr-x  77 root   wheel    119008 Apr 20 12:52 gcc
    -rwxr-xr-x  77 root   wheel    119008 Apr 20 12:52 llvm-g++
    -rwxr-xr-x  77 root   wheel    119008 Apr 20 12:52 llvm-gcc
    ```

=== "cmdbin"

    ```Shell
    $ ls -l $cmdbin | grep -E "clang|cpp|(cc|gcc)$|[g|c]\+\+"
    lrwxr-xr-x  1 root  wheel          5 Mar  8 00:55 c++ -> clang
    lrwxr-xr-x  1 root  wheel          5 Mar  8 00:55 cc -> clang
    -rwxr-xr-x  1 root  wheel  251484800 Feb 23 10:06 clang
    lrwxr-xr-x  1 root  wheel          5 Mar  8 00:55 clang++ -> clang
    lrwxr-xr-x  1 root  wheel          3 Mar  8 00:55 g++ -> gcc
    -rwxr-xr-x  1 root  admin       3344 Feb  3 02:02 cpp
    -rwxr-xr-x  1 root  admin     101088 Feb 23 10:06 gcc
    ```

=== "xcdevbin"

    ```Shell
    $ ls -l $xcdevbin | grep -E "clang|cpp|(cc|gcc)$|[g|c]\+\+"
    lrwxr-xr-x  1 root  wheel         3 Mar  6 13:05 g++ -> gcc
    -rwxr-xr-x  1 root  wheel    101088 Feb 23 10:06 gcc
    ```

=== "xctcbin"

    ```Shell
    $ ls -l $xctcbin | grep -E "clang|cpp|(cc|gcc)$|[g|c]\+\+"
    lrwxr-xr-x  1 root  wheel          5 Mar  6 13:04 c++ -> clang
    lrwxr-xr-x  1 root  wheel          5 Mar  6 13:04 cc -> clang
    -rwxr-xr-x  1 root  wheel  251484800 Feb 23 10:06 clang
    lrwxr-xr-x  1 root  wheel          5 Mar  6 13:04 clang++ -> clang
    -rwxr-xr-x  1 root  wheel       3344 Feb  3 02:01 cpp
    ```

从输出结果来看，有些是二进制实体文件，有些是软链替身。四个目录实际上是两套工具链：

1. 系统 /usr/bin 下的 clang++, cpp, gcc/cc, g++/c++ 和 clang 是同一份实体（size 和 md5 一致）。
2. Xcode Command Line Tools（cmdbin）下，clang++ 和 cc/c++ 均指向 clang ，g++ 指向 gcc。

### llvm-gcc binutils

执行以下 Shell 命令，可以查看散落在四个 */usr/bin 目录下的 Binutils：

```Shell
usrbin=/usr/bin
cmdbin=/Library/Developer/CommandLineTools/usr/bin
xcdevpath=`xcode-select -p` # /Applications/Xcode.app/Contents/Developer
xcdevbin=$xcdevpath/usr/bin
xctcbin=$xcdevpath/Toolchains/XcodeDefault.xctoolchain/usr/bin

comm -12 <(ls $usrbin) <(ls $cmdbin)
comm -12 <(ls $usrbin) <(ls $xcdevbin)
comm -12 <(ls $usrbin) <(ls $xctcbin)
```

clang 相比 gcc 少了以下命令：

- `gold`: [The LLVM gold plugin](https://llvm.org/docs/GoldPlugin.html)
- `addr2line`: [llvm-addr2line - a drop-in replacement for addr2line](https://llvm.org/docs/CommandGuide/llvm-addr2line.html)
- `elfedit`: segedit
- `objcopy`: [llvm-objcopy - object copying and editing tool](https://llvm.org/docs/CommandGuide/llvm-objcopy.html)
- `readelf`: [llvm-readelf - GNU-style LLVM Object Reader](https://llvm.org/docs/CommandGuide/llvm-readelf.html)

clang 相比 gcc 多了以下命令：

- `cmpdylib` - compare two dynamic shared libraries for compatibility
- `dsymutil` - manipulate archived DWARF debug symbol files
- `dwarfdump` - dump and verify DWARF debug information
- `indent` – indent and format C program source
- `install_name_tool` - change dynamic shared library install names
- `libtool` - create libraries
- `lipo` - create or operate on universal files
- `lorder` – list dependencies for object files
- `nmedit` - change global symbols to local symbols
- `otool`(-classic) - object file displaying tool. `otool -L` 对应 Linux 下的 `ldd`。
- `segedit` - extract and replace sections from object files
- `unifdef`, unifdefall – remove preprocessor conditionals from code
- `vtool` – Mach-O version number utility

[Cross-compilation using Clang](https://clang.llvm.org/docs/CrossCompilation.html)
[Building Linux with Clang/LLVM — The Linux Kernel documentation](https://docs.kernel.org/kbuild/llvm.html)

```Shell
make CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm STRIP=llvm-strip \
  OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf \
  HOSTCC=clang HOSTCXX=clang++ HOSTAR=llvm-ar HOSTLD=ld.lld
```

### Language Standards

[Clang - C Programming Language Status](https://clang.llvm.org/c_status.html)
[Clang - C++ Programming Language Status](https://clang.llvm.org/cxx_status.html)

[clang - the Clang C, C++, and Objective-C compiler](https://clang.llvm.org/docs/CommandGuide/clang.html)

OPTIONS | Language Selection and Mode Options:

```Shell
-x <language>
Treat subsequent input files as having type language.

-ansi
Same as -std=c89.

-std=<standard>
Specify the c/c++ language standard to compile for.

The default C language standard is gnu17, except on PS4, where it is gnu99.
The default C++ language standard is gnu++17.

-stdlib=<library>
Specify the C++ standard library to use; supported options are libstdc++ (GNU GCC) and libc++ (Clang). If not specified, platform default will be used.
```

[Clang command line argument reference](https://clang.llvm.org/docs/ClangCommandLineReference.html)

Introduction:

```Shell
-std-default=<arg>
-stdlib=<arg>, --stdlib=<arg>, --stdlib <arg>
C++ standard library to use. <arg> must be ‘libc++’, ‘libstdc++’ or ‘platform’.
```

Compilation options:

```Shell
-std=<arg>, --std=<arg>, --std <arg>
Language standard to compile for
```

[Compiler Specifics — alpaka 1.0.0-rc1 documentation](https://alpaka.readthedocs.io/en/latest/advanced/compiler.html)

[C++ Language Support - Xcode - Apple Developer](https://developer.apple.com/xcode/cpp/)

Apple supports C++ with the Apple `Clang` compiler (included in Xcode) and the `libc++` C++ standard library runtime (included in SDKs and operating systems). The compiler and runtime are regularly updated to offer new functionality, including many leading-edge features specified by the ISO C++ standard.

关于静态链接，参考 [Clang command line argument reference](https://clang.llvm.org/docs/ClangCommandLineReference.html) 相关选项：

- -static-libgcc
- -static-libstdc++

#### libc

[C Language Features](https://clang.llvm.org/docs/UsersManual.html#c-language-features)

[llvm-libc](https://libc.llvm.org/) is an incomplete, upcoming, ABI independent C standard library designed by and for the LLVM project.

Xcode Project Settings | Language | C Language Dialect 对应 project.pbxproj 中 buildSettings 字典的 key = `GCC_C_LANGUAGE_STANDARD`。

#### libc++

[C++ Language Features](https://clang.llvm.org/docs/UsersManual.html#cxx)

The LLVM project includes an implementation of the C++ Standard Library named [libc++](https://libcxx.llvm.org/), dual-licensed under the MIT License and the UIUC license.

Xcode Project Settings | Language - C++:

- C++ Language Dialect 对应 project.pbxproj 中 buildSettings 字典的 key = `CLANG_CXX_LANGUAGE_STANDARD`。
- C++ Standard Library 对应 project.pbxproj 中 buildSettings 字典的 key = `CLANG_CXX_LIBRARY`。

### LLDB

[Controlling Debug Information](https://clang.llvm.org/docs/UsersManual.html#controlling-debug-information)
[Debug information generation](https://clang.llvm.org/docs/ClangCommandLineReference.html#debug-information-generation)

[LLDB](https://lldb.llvm.org/) - [wiki](https://en.wikipedia.org/wiki/LLDB_(debugger))

- [GDB to LLDB command map](https://lldb.llvm.org/use/map.html)
- [Tutorial](https://lldb.llvm.org/use/tutorial.html)
- [Debugging](https://lldb.llvm.org/resources/debugging.html)

[Getting Started with LLDB](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/gdb_to_lldb_transition_guide/document/lldb-basics.html)
[GDB and LLDB Command Examples](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/gdb_to_lldb_transition_guide/document/lldb-command-examples.html)

[Dancing in the Debugger — A Waltz with LLDB](https://www.objc.io/issues/19-debugging/lldb-debugging/)
[ObjC 中国 - 与调试器共舞 - LLDB 的华尔兹](https://objccn.io/issue-19-2/)

## MSVC

[MSVC](https://en.wikipedia.org/wiki/Microsoft_Visual_C%2B%2B)

[Install Visual Studio](https://learn.microsoft.com/en-us/visualstudio/install/install-visual-studio?view=vs-2022)
[Visual Studio documentation](https://learn.microsoft.com/en-us/visualstudio/windows/?view=vs-2022)

### Binutils

[C/C++ projects and build systems in Visual Studio](https://learn.microsoft.com/en-us/cpp/build/projects-and-build-systems-cpp?view=msvc-170&redirectedfrom=MSDN)

Compiler and build tools reference - [C/C++ Building Reference - Visual Studio](https://learn.microsoft.com/en-us/cpp/build/reference/c-cpp-building-reference?view=msvc-170)

[Use the Microsoft C++ toolset from the command line](https://learn.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=msvc-170&redirectedfrom=MSDN)

Win10 下安装的 VS2015，VC Binutils 在 `C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin` 目录下：

- [CL](https://learn.microsoft.com/en-us/cpp/build/reference/compiling-a-c-cpp-program?view=msvc-170): Use the compiler (`cl.exe`) to compile and link source code files into apps, libraries, and DLLs.
- [Link](https://learn.microsoft.com/en-us/cpp/build/reference/linking?view=msvc-170): Use the linker (`link.exe`) to link compiled object files and libraries into apps and DLLs.

- [LIB.EXE](https://learn.microsoft.com/en-us/cpp/build/reference/lib-reference?view=msvc-170) is used to create and manage a library of Common Object File Format (COFF) object files. It can also be used to create export files and import libraries to reference exported definitions.
- [EDITBIN.EXE](https://learn.microsoft.com/en-us/cpp/build/reference/editbin-reference?view=msvc-170) is used to modify COFF binary files.
- [DUMPBIN.EXE](https://learn.microsoft.com/en-us/cpp/build/reference/dumpbin-reference?view=msvc-170) displays information (such as a symbol table) about COFF binary files.
- [Decorated names](https://learn.microsoft.com/en-us/cpp/build/reference/decorated-names?view=msvc-170) - Viewing undecorated names: You can use `undname.exe` to convert a decorated name to its undecorated form. ref to [Demangling in MSVC - c++](https://stackoverflow.com/questions/13777681/demangling-in-msvc).

[NMAKE](https://learn.microsoft.com/en-us/cpp/build/reference/nmake-reference?view=msvc-170): Use NMAKE (`nmake.exe`) reads and executes makefiles, to build C++ projects by using a traditional makefile.

[CMake](https://learn.microsoft.com/en-us/cpp/build/cmake-projects-in-visual-studio?view=msvc-170): CMake (`cmake.exe`) is a cross-platform, open-source tool for defining build processes that run on multiple platforms.

[CMake projects in Visual Studio](https://learn.microsoft.com/en-us/cpp/build/cmake-projects-in-visual-studio?view=msvc-170)

- [Walkthrough: Build and Debug C++ with Microsoft Windows Subsystem for Linux 2 (WSL 2) and Visual Studio 2022](https://learn.microsoft.com/en-us/cpp/build/walkthrough-build-debug-wsl2?view=msvc-170)
- [Clang/LLVM support in Visual Studio CMake projects](https://learn.microsoft.com/en-us/cpp/build/clang-support-cmake?view=msvc-170)

### Language Standards

[/std (Specify Language Standard Version)](https://learn.microsoft.com/en-us/cpp/build/reference/std-specify-language-standard-version?view=msvc-170)

[Microsoft C++ compiler versions](https://learn.microsoft.com/en-us/cpp/overview/compiler-versions?view=msvc-170)

[C and C++ in Visual Studio](https://learn.microsoft.com/en-us/cpp/overview/visual-cpp-in-visual-studio?view=msvc-170)
[Microsoft C/C++ language conformance](https://learn.microsoft.com/en-us/cpp/overview/visual-cpp-language-conformance?view=msvc-170)
[C++ conformance improvements in Visual Studio 2022](https://learn.microsoft.com/en-us/cpp/overview/cpp-conformance-improvements?view=msvc-170)

[Microsoft C/C++ Documentation](https://learn.microsoft.com/en-us/cpp/?view=msvc-160): C++, C, and Assembler
[C runtime library reference](https://learn.microsoft.com/en-us/cpp/c-runtime-library/c-run-time-library-reference?view=msvc-160)
[Universal C runtime routines by category](https://learn.microsoft.com/en-us/cpp/c-runtime-library/run-time-routines-by-category?view=msvc-160)

[C/C++ language and standard libraries reference](https://learn.microsoft.com/en-us/cpp/cpp/c-cpp-language-and-standard-libraries)

### WinDbg

[First look at the debugger - Visual Studio (Windows)](https://learn.microsoft.com/en-us/visualstudio/debugger/debugger-feature-tour?view=vs-2022)

[Debugging Tools for Windows - Windows drivers](https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/debugger-download-tools)

[WinDbg](http://www.windbg.org/) - [wiki](https://en.wikipedia.org/wiki/WinDbg)

[Install WinDbg](https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/)
