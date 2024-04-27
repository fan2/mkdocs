---
title: Mainstream Compiler - gcc/clang/msvc
authors:
  - xman
date:
    created: 2009-10-04T10:00:00
    updated: 2024-04-02T10:00:00
categories:
    - toolchain
comments: true
---

Mainstream Compiler: GNU/GCC, LLVM/Clang, Microsoft Visual Studio.

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

[GCC, the GNU Compiler Collection](https://gcc.gnu.org/) - [wiki](https://en.wikipedia.org/wiki/GNU_Compiler_Collection)
[GCC online documentation](https://gcc.gnu.org/onlinedocs/)

- [Option Summary](https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html)
- [Overall Options](https://gcc.gnu.org/onlinedocs/gcc/Overall-Options.html)

### Binutils

[GNU Hurd / GNU Binutils](https://www.gnu.org/savannah-checkouts/gnu/hurd/binutils.html) - [GNU Binutils](https://www.gnu.org/software/binutils/)

[cpp - The C Preprocessor](https://gcc.gnu.org/onlinedocs/cpp/)

- [Options Controlling the Preprocessor](https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html)

compile C/C++:

- compile C: `cc` / `gcc`

    - c89 - ANSI (1989) C compiler
    - c99 - ANSI (1999) C compiler

- compile C++: `c++` / `g++`

!!! info "gcc or g++?"

    [Invoking G++ - Compiling C++ Programs](https://gcc.gnu.org/onlinedocs/gcc/Invoking-G_002b_002b.html)

    GCC recognizes C++ header/source files with these names and compiles them as C++ programs even if you call the compiler the same way as for compiling C programs (usually with the name `gcc`).

    However, the use of `gcc` does not add the C++ library. `g++` is a program that calls GCC and automatically specifies linking against the C++ library. It treats ‘.c’, ‘.h’ and ‘.i’ files as C++ source files instead of C source files unless `-x` is used. This program is also useful when precompiling a C header file with a ‘.h’ extension for use in C++ compilations. On many systems, `g++` is also installed with the name `c++`.

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
- `ranlib` - Generates an index to the contents of an archive.
- `readelf` - Displays information from any ELF format object file.
- `size` - Lists the section sizes of an object or archive file.
- `strip` - Discards symbols.

在 Linux(Ubuntu) 下，这些 GNU Binutils 被预装在 `/usr/bin/` 目录下。

其他相命令：

- `ldd` - print shared object dependencies

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

使用 gcc 编译链接的时候，默认是采用动态链接的方式。如果要指定 [静态链接](https://www.cnblogs.com/motadou/p/4471088.html)，有两种方式：

1. 使用 `-static` 选项，开启全静态链接。
2. 使用 `-Wl,-Bstatic`，`-Wl,-Bdynamic` 选项，将部分动态库设置为静态链接。

参考 GCC [Link Options](https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html) 相关选项：

- -static
- -static-libgcc
- -static-libstdc++

#### glibc

[The GNU C Library](https://www.gnu.org/software/libc/) - [wiki](https://en.wikipedia.org/wiki/Glibc)

- [sourceware](https://sourceware.org/glibc/)
- [Index of /gnu/libc](https://ftp.gnu.org/gnu/libc/)
- [Documentation for the GNU C Library](https://sourceware.org/glibc/manual/)

[libc、glib、glibc 简介](https://www.cnblogs.com/arci/p/14591030.html)，[libc、glibc 和 glib 的关系](https://blog.csdn.net/yasi_xi/article/details/9899599)
[c - What is the role of libc(glibc) in our linux app?](https://stackoverflow.com/questions/11372872/what-is-the-role-of-libcglibc-in-our-linux-app)

glibc 和 libc 都是 Linux 下的 C 函数库：

1. libc 是 Linux 下的 ANSI C 函数库；
2. glibc 是 Linux 下的 GUN C 函数库。

glibc（即 GNU C Library）本身是GNU旗下的C标准库，后来逐渐成为了Linux的标准C库，而Linux下原来的标准C库 [libc](http://www.musl-libc.org/) 逐渐不再被维护。

??? note "获取查看 glibc 版本号"

    [glibc 查看版本号](https://www.cnblogs.com/motadou/p/4473966.html)：

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

[GNU Hurd / GNU GDB](https://www.gnu.org/savannah-checkouts/gnu/hurd/gdb.html) - [GDB](https://www.sourceware.org/gdb/) - [docs](https://sourceware.org/gdb/download/onlinedocs/) - [wiki](https://en.wikipedia.org/wiki/GNU_Debugger)

[GDB online](https://www.onlinegdb.com/)

用GDB调试程序：[（一）](https://haoel.blog.csdn.net/article/details/2879) ～ [（七）](https://haoel.blog.csdn.net/article/details/2885)

## LLVM/Clang

In 2006, [Chris Lattner](https://nondot.org/sabre/) started working on a new project named Clang. The combination of Clang *frontend* and LLVM *backend* is named Clang/LLVM or simply Clang.

[The LLVM Compiler Infrastructure Project](https://llvm.org/) - [wiki](https://en.wikipedia.org/wiki/LLVM) @[github](https://github.com/llvm/llvm-project)

- [LLVM's Documentation](https://llvm.org/docs/)

[Clang C Language Family Frontend for LLVM](https://clang.llvm.org/) - [wiki](https://en.wikipedia.org/wiki/Clang)

- [Clang's documentation](https://clang.llvm.org/docs/)
- [Clang Compiler User’s Manual](https://clang.llvm.org/docs/UsersManual.html)
- [clang - the Clang C, C++, and Objective-C compiler](https://clang.llvm.org/docs/CommandGuide/clang.html)
- [Clang command line argument reference](https://clang.llvm.org/docs/ClangCommandLineReference.html)

---

[Introduction to the LLVM Compiler System](https://llvm.org/pubs/2008-10-04-ACAT-LLVM-Intro.html)

[The Architecture of Open Source Applications (Volume 1) LLVM](https://aosabook.org/en/v1/llvm.html)

Three Major Components of a Three-Phase Compiler:

![Classical-Three-Phase-Compiler](https://aosabook.org/static/llvm/SimpleCompiler.png)

![Compiler_design-Three-stage-compiler-structure](./images/Compiler_design-Three-stage-compiler-structure.png)

Implications of this Design - Retargetablity:

![Retargetablity](https://aosabook.org/static/llvm/RetargetableCompiler.png)

LLVM's Implementation of Three-Phase Design:

![LLVM's Implementation of the Three-Phase Design](https://aosabook.org/static/llvm/LLVMCompiler1.png)

### Binutils

!!! abstract "LLVM Linker"

    The `lld` subproject is an attempt to develop a built-in, platform-independent linker for LLVM. lld aims to remove dependence on a third-party linker. As of May 2017, lld supports [ELF](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format), [PE/COFF](https://en.wikipedia.org/wiki/PE/COFF), [Mach-O](https://en.wikipedia.org/wiki/Mach-O), and [WebAssembly](https://en.wikipedia.org/wiki/WebAssembly) in descending order of completeness. lld is faster than both flavors of GNU ld.

    Unlike the GNU linkers, lld has built-in support for [link-time optimization](https://en.wikipedia.org/wiki/Link-time_optimization) (LTO). This allows for faster code generation as it bypasses the use of a linker plugin, but on the other hand prohibits interoperability with other flavors of LTO.

[Clang Performance and GCC compatibility](https://en.wikipedia.org/wiki/Clang#Performance_and_GCC_compatibility)

> Clang Compiler Driver (Drop-in Substitute for GCC): The clang tool is the compiler driver and front-end, which is designed to be a drop-in replacement for the gcc command.

!!! abstract "GCC compatibility"

    Clang is compatible with GCC. Its command-line interface shares many of GCC's flags and options. Clang implements many GNU language extensions and compiler intrinsics, some of which are purely for compatibility. For example, even though Clang implements atomic intrinsics which correspond exactly with C11 atomics, it also implements GCC's __sync_* intrinsics for compatibility with GCC and libstdc++. Clang also maintains ABI compatibility with GCC-generated object code. In practice, Clang is a drop-in replacement for GCC.

[gcc - Is there a binutils for llvm? - Stack Overflow](https://stackoverflow.com/questions/5238582/is-there-a-binutils-for-llvm)

[Preprocessor options](https://clang.llvm.org/docs/ClangCommandLineReference.html#preprocessor-options)

#### llvm-gcc/llvm-g++

```Shell
$ clang --version
Apple clang version 15.0.0 (clang-1500.3.9.4)
Target: arm64-apple-darwin23.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

$ which clang
/usr/bin/clang

$ clang++ --version
Apple clang version 15.0.0 (clang-1500.3.9.4)
Target: arm64-apple-darwin23.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

$ which clang++
/usr/bin/clang++
```

在 macOS 中，`gcc` 以某种方式指向 llvm-gcc 编译器，g++ 亦如此。

> In Apple's version of GCC, both cc and gcc are actually symbolic links to the llvm-gcc compiler. Similarly, c++ and g++ are links to llvm-g++.

`llvm-gcc` 是 c/c++/oc 的编译器，用了 gcc 前端和命令行界面的 llvm。

> llvm-gcc is a C, C++, Objective-C and Objective-C++ compiler. llvm-g++ is a compiler driver for C++. llvm-gcc uses gcc front-end and gcc's command line interface.

```Shell
$ gcc --version
Apple clang version 15.0.0 (clang-1500.3.9.4)
Target: arm64-apple-darwin23.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

$ which llvm-gcc
/usr/bin/llvm-gcc

$ which gcc
/usr/bin/gcc
```

```Shell
$ g++ --version
Apple clang version 15.0.0 (clang-1500.3.9.4)
Target: arm64-apple-darwin23.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

$ which llvm-g++
/usr/bin/llvm-g++

$ which g++
/usr/bin/g++
```

由 `gcc --version` 和 `g++ --version` 输出的 InstalledDir 可以看出，gcc/g++ 实际上是 XcodeDefault.xctoolchain 下 clang/clang++ 的 [shims or wrapper](http://stackoverflow.com/questions/9329243/xcode-4-4-and-later-install-command-line-tools/) executables。

cc、c++ 均为 clang 的软链：

```Shell
$ xcrun -f cpp
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cpp

$ cpp --version
Apple clang version 15.0.0 (clang-1500.3.9.4)
Target: arm64-apple-darwin23.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

$ which cpp
/usr/bin/cpp

$ xcrun -f cc
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc

# print the path of the active developer directory
xcdevpath=`xcode-select -p` # /Applications/Xcode.app/Contents/Developer
$ readlink $xcdevpath/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc
clang

$ xcrun -f c++
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++

$ readlink $xcdevpath/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++
clang
```

#### llvm-gcc vs. GNU/gcc

macOS 下有四个 */usr/bin 目录下散落着 llvm/clang 工具链：

1. /usr/bin
2. /Library/Developer/CommandLineTools/usr/bin - ref [CommandLineTools](https://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/)
3. $xcdevpath/usr/bin
4. $xcdevpath/Toolchains/XcodeDefault.xctoolchain/usr/bin

```Shell
usrbin=/usr/bin
cmdbin=/Library/Developer/CommandLineTools/usr/bin
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
