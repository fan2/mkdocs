---
title: GCC Compilation Quick Tour - dynamic
authors:
    - xman
date:
    created: 2023-06-17T10:00:00
categories:
    - elf
comments: true
---

The compilation is the process of converting the source code of the C language into machine code.

As C is a mid-level language, it needs a compiler to convert it into an executable code so that the program can be run on our machine.

In this article, let's do a hands-on practice to take a close look at the basic compilation of C program with GCC.

<!-- more -->

Let's start by exploring the installed gcc compiler toolchain. First, let's look at the host machine on which it resides.

```bash
$ uname -a
Linux rpi3b-ubuntu 5.15.0-1055-raspi #58-Ubuntu SMP PREEMPT Sat May 4 03:52:40 UTC 2024 aarch64 aarch64 aarch64 GNU/Linux
```

## explore toolchain

Explore `gcc` entity(real body):

```bash
$ which gcc
/usr/bin/gcc
$ readlink `which gcc`
gcc-11
$ which gcc-11
/usr/bin/gcc-11
$ readlink `which gcc-11`
aarch64-linux-gnu-gcc-11
```

Show `gcc` version:

```bash
# gcc version
$ gcc --version
gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

$ gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/lib/gcc/aarch64-linux-gnu/11/lto-wrapper
Target: aarch64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu 11.4.0-1ubuntu1~22.04' --with-bugurl=file:///usr/share/doc/gcc-11/README.Bugs --enable-languages=c,ada,c++,go,d,fortran,objc,obj-c++,m2 --prefix=/usr --with-gcc-major-version-only --program-suffix=-11 --program-prefix=aarch64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --enable-bootstrap --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-libquadmath --disable-libquadmath-support --enable-plugin --enable-default-pie --with-system-zlib --enable-libphobos-checking=release --with-target-system-zlib=auto --enable-objc-gc=auto --enable-multiarch --enable-fix-cortex-a53-843419 --disable-werror --enable-checking=release --build=aarch64-linux-gnu --host=aarch64-linux-gnu --target=aarch64-linux-gnu --with-build-config=bootstrap-lto-lean --enable-link-serialization=2
Thread model: posix
Supported LTO compression algorithms: zlib zstd
gcc version 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04)
```

Show `as`/`ld` version:

```bash
$ which as
/usr/bin/as
$ readlink `which as`
aarch64-linux-gnu-as

$ as -v
GNU assembler version 2.38 (aarch64-linux-gnu) using BFD version (GNU Binutils for Ubuntu) 2.38
^C

$ as --version
GNU assembler (GNU Binutils for Ubuntu) 2.38
Copyright (C) 2022 Free Software Foundation, Inc.
This program is free software; you may redistribute it under the terms of
the GNU General Public License version 3 or later.
This program has absolutely no warranty.
This assembler was configured for a target of `aarch64-linux-gnu'.

$ which ld
/usr/bin/ld
$ readlink `which ld`
aarch64-linux-gnu-ld

$ ld -v
GNU ld (GNU Binutils for Ubuntu) 2.38

$ ld --version
GNU ld (GNU Binutils for Ubuntu) 2.38
Copyright (C) 2022 Free Software Foundation, Inc.
This program is free software; you may redistribute it under the terms of
the GNU General Public License version 3 or (at your option) a later version.
This program has absolutely no warranty.
```

## gcc compile

GCC - [Overall Options](https://gcc.gnu.org/onlinedocs/gcc/Overall-Options.html)

```bash
-v
Print (on standard error output) the commands executed to run the stages of compilation. Also print the version number of the compiler driver program and of the preprocessor and the compiler proper.

-###
Like -v except the commands are not executed and arguments are quoted unless they contain only alphanumeric characters or ./-_. This is useful for shell scripts to capture the driver-generated command lines.
```

Do a trial run with `-###`: `gcc -## 0701.c`. Use this to see what gcc would do without actually doing it.

Do compile `0701.c` with verbose logging by `gcc -v 0701.c`:

!!! info ""

    1. /usr/lib/gcc/aarch64-linux-gnu/11/`cc1` 0701.c -o /tmp/ccm9rMTX.s
    2. `as` -v -EL -mabi=lp64 -o /tmp/ccMWnd3L.o /tmp/ccm9rMTX.s
    3. /usr/lib/gcc/aarch64-linux-gnu/11/`collect2` /lib/ld-linux-aarch64.so.1 Scrt1.o crti.o crtbeginS.o /tmp/ccMWnd3L.o -lc -lgcc crtendS.o crtn.o

```bash
$ gcc -v 0701.c
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/lib/gcc/aarch64-linux-gnu/11/lto-wrapper
Target: aarch64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu 11.4.0-1ubuntu1~22.04' --with-bugurl=file:///usr/share/doc/gcc-11/README.Bugs --enable-languages=c,ada,c++,go,d,fortran,objc,obj-c++,m2 --prefix=/usr --with-gcc-major-version-only --program-suffix=-11 --program-prefix=aarch64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --enable-bootstrap --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-libquadmath --disable-libquadmath-support --enable-plugin --enable-default-pie --with-system-zlib --enable-libphobos-checking=release --with-target-system-zlib=auto --enable-objc-gc=auto --enable-multiarch --enable-fix-cortex-a53-843419 --disable-werror --enable-checking=release --build=aarch64-linux-gnu --host=aarch64-linux-gnu --target=aarch64-linux-gnu --with-build-config=bootstrap-lto-lean --enable-link-serialization=2
Thread model: posix
Supported LTO compression algorithms: zlib zstd
gcc version 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04)
COLLECT_GCC_OPTIONS='-v' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'a-'
 /usr/lib/gcc/aarch64-linux-gnu/11/cc1 -quiet -v -imultiarch aarch64-linux-gnu 0701.c -quiet -dumpdir a- -dumpbase 0701.c -dumpbase-ext .c -mlittle-endian -mabi=lp64 -version -fasynchronous-unwind-tables -fstack-protector-strong -Wformat -Wformat-security -fstack-clash-protection -o /tmp/ccm9rMTX.s
GNU C17 (Ubuntu 11.4.0-1ubuntu1~22.04) version 11.4.0 (aarch64-linux-gnu)
	compiled by GNU C version 11.4.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

GGC heuristics: --param ggc-min-expand=91 --param ggc-min-heapsize=115878
ignoring nonexistent directory "/usr/local/include/aarch64-linux-gnu"
ignoring nonexistent directory "/usr/lib/gcc/aarch64-linux-gnu/11/include-fixed"
ignoring nonexistent directory "/usr/lib/gcc/aarch64-linux-gnu/11/../../../../aarch64-linux-gnu/include"
#include "..." search starts here:
#include <...> search starts here:
 /usr/lib/gcc/aarch64-linux-gnu/11/include
 /usr/local/include
 /usr/include/aarch64-linux-gnu
 /usr/include
End of search list.
GNU C17 (Ubuntu 11.4.0-1ubuntu1~22.04) version 11.4.0 (aarch64-linux-gnu)
	compiled by GNU C version 11.4.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

GGC heuristics: --param ggc-min-expand=91 --param ggc-min-heapsize=115878
Compiler executable checksum: 52ed857e9cd110e5efaa797811afcfbb
COLLECT_GCC_OPTIONS='-v' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'a-'
 as -v -EL -mabi=lp64 -o /tmp/ccMWnd3L.o /tmp/ccm9rMTX.s
GNU assembler version 2.38 (aarch64-linux-gnu) using BFD version (GNU Binutils for Ubuntu) 2.38
COMPILER_PATH=/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/:/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/
LIBRARY_PATH=/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../../lib/:/lib/aarch64-linux-gnu/:/lib/../lib/:/usr/lib/aarch64-linux-gnu/:/usr/lib/../lib/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../:/lib/:/usr/lib/
COLLECT_GCC_OPTIONS='-v' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'a.'
 /usr/lib/gcc/aarch64-linux-gnu/11/collect2 -plugin /usr/lib/gcc/aarch64-linux-gnu/11/liblto_plugin.so -plugin-opt=/usr/lib/gcc/aarch64-linux-gnu/11/lto-wrapper -plugin-opt=-fresolution=/tmp/ccyiqbzK.res -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s -plugin-opt=-pass-through=-lc -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s --build-id --eh-frame-hdr --hash-style=gnu --as-needed -dynamic-linker /lib/ld-linux-aarch64.so.1 -X -EL -maarch64linux --fix-cortex-a53-843419 -pie -z now -z relro /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/Scrt1.o /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/crti.o /usr/lib/gcc/aarch64-linux-gnu/11/crtbeginS.o -L/usr/lib/gcc/aarch64-linux-gnu/11 -L/usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu -L/usr/lib/gcc/aarch64-linux-gnu/11/../../../../lib -L/lib/aarch64-linux-gnu -L/lib/../lib -L/usr/lib/aarch64-linux-gnu -L/usr/lib/../lib -L/usr/lib/gcc/aarch64-linux-gnu/11/../../.. /tmp/ccMWnd3L.o -lgcc --push-state --as-needed -lgcc_s --pop-state -lc -lgcc --push-state --as-needed -lgcc_s --pop-state /usr/lib/gcc/aarch64-linux-gnu/11/crtendS.o /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/crtn.o
COLLECT_GCC_OPTIONS='-v' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'a.'
```

### COLLECT_GCC

What does the first two lines mean?

- Using built-in specs.
- COLLECT_GCC=gcc

[Mainstream Compiler](../toolchain/mainstream-compiler.md) - [GNU C Compiler Internals/Architecture](https://en.wikibooks.org/wiki/GNU_C_Compiler_Internals/GNU_C_Compiler_Architecture)

For a C source file they are the preprocessor and compiler `cc1`, the assembler `as`, and the linker `collect2`. The first and the third programs come with a GCC *distribution*, the assembler is a part of the GNU *binutils* package.

<figure markdown="span">
    ![GCC_Architecture](../toolchain/images/GCC_Architecture.jpeg)
</figure>

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

### configure

At this time, let's get acquainted with the following configure items:

- --prefix=/usr --with-gcc-major-version-only --program-suffix=-11 --program-prefix=aarch64-linux-gnu- // usr/bin/aarch64-linux-gnu-[gcc,as,ld]-11
- --enable-shared // dynamic link shared library(glibc)
- --enable-linker-build-id
- --libexecdir=/usr/lib
- --without-included-gettext
- --enable-threads=posix
- --libdir=/usr/lib
- --enable-plugin
- --enable-default-pie
- --enable-multiarch
- --enable-fix-cortex-a53-843419
- --build=aarch64-linux-gnu
- --host=aarch64-linux-gnu
- --target=aarch64-linux-gnu

Please refer to the following links to get a knowledge of `libexecdir` and `libdir`:

- [Directory Variables (GNU Coding Standards)](https://www.gnu.org/prep/standards/html_node/Directory-Variables.html)
- [Installation Directory Variables (Autoconf)](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/Installation-Directory-Variables.html)

In the future, when the time is right, we will carry out further exploration.

### COLLECT_GCC_OPTIONS

1. `-mlittle-endian` / as `-EL`: specify endianess, refer to [Byte Order(Endianess)](../cs/byte-order-endianess.md).
2. `-mabi=lp64`: specify data model, refer to [Data Models](../cs/data-model.md).

### collect2

[Options (LD)](https://sourceware.org/binutils/docs/ld/Options.html): 

> `[-L searchdir|--library-path=searchdir]`: Add path *searchdir* to the list of paths that `ld` will search for archive libraries and `ld` control scripts.

Simplify `LIBRARY_PATH`, the searchdir is as follows:

- /usr/lib/gcc/aarch64-linux-gnu/11/
- /usr/lib/aarch64-linux-gnu/
- /usr/lib/
- /lib/aarch64-linux-gnu/
- /lib/

Deduplication to just two root paths: `/usr/lib/`, `/lib/`.

Ignore anything that's blocking the view, the remaining core is as follows.

```bash
-dynamic-linker /lib/ld-linux-aarch64.so.1

/usr/lib/aarch64-linux-gnu/Scrt1.o
/usr/lib/aarch64-linux-gnu/crti.o
/usr/lib/gcc/aarch64-linux-gnu/11/crtbeginS.o

/tmp/ccMWnd3L.o

-lgcc
--push-state --as-needed -lgcc_s --pop-state
-lc
-lgcc
--push-state --as-needed -lgcc_s --pop-state

/usr/lib/gcc/aarch64-linux-gnu/11/crtendS.o
/usr/lib/aarch64-linux-gnu/crtn.o
```

You should have noticed that `/tmp/ccMWnd3L.o` is exactly the direct assembler product of our C code (0701.c), surrounded by C runtime object code and linker facilities.

I won't go into the details of the linking procedure at this point, but let's figure out what the link input is first.

#### CRT object

!!! note "Why does C runtime code come in the form of object code files?"

    《[C语言标准与实现](https://att.newsmth.net/nForum/att/CProgramming/3213/245)》 | 07 C 源文件的编译和链接

    In a C program, `_start` must be provided by the C runtime code. If the runtime code is placed in the library file, we cannot guarantee that `ld` will definitely copy these codes into the executable. 07-01 is a good example, it does not reference any other symbols. In this case, the code represented by `_start` cannot be copied into the executable by `ld`. Therefore, in the end, `ld` will not be able to find the starting point of execution `_start`, which will produce incorrect output.

    Therefore, the C runtime code *must* be linked as an object code file. We all know that when `ld` links the object code file, it copies all the ".data" area, ".text" area, ".bss" area, etc. of each object code file into the executable file. This ensures that `ld` will eventually find `_start` for sure.

For more information on CRT(C Runtime), please refer to [crtbegin.o vs. crtbeginS.o](https://stackoverflow.com/questions/22160888/what-is-the-difference-between-crtbegin-o-crtbegint-o-and-crtbegins-o) and [Mini FAQ about the misc libc/gcc crt files.](https://dev.gentoo.org/~vapier/crt.txt).

1. /usr/lib/aarch64-linux-gnu/**`Scrt1.o`**: Used in place of `crt1.o` when generating PIEs.
2. /usr/lib/aarch64-linux-gnu/**`crti.o`**: Defines the function *prologs* for the `.init` and `.fini` sections (with the `_init` and `_fini` symbols respectively).
3. /usr/lib/gcc/aarch64-linux-gnu/11/**`crtbeginS.o`**: Used in place of `crtbegin.o` when generating shared objects/PIEs.
4. /usr/lib/gcc/aarch64-linux-gnu/11/**`crtendS.o`**: Used in place of `crtend.o` when generating shared objects/PIEs.
5. /usr/lib/aarch64-linux-gnu/**`crtn.o`**: Defines the function *epilogs* for the `.init`/`.fini` sections.

Now, let's find out all the related CRT object code files.

```bash
# rough ls-grep
# ls -l /usr/lib/* /lib/* | grep -iE "crt.*\.[o|s]"
# find the most
# find /usr/lib/ /lib/ -type f -iname "*crt*\.*"
# limit suffix
# find /usr/lib/ /lib/ -type f -iname "*crt*\.o"
# specify filename pattern
# find /usr/lib/ /lib/ -type f -regextype egrep -iregex ".*crt(begin|end|1|i|n)?(S|T)?\.o"
# exclude gcc-corss(! = -not)
# find /usr/lib/ /lib/ ! -path "*/gcc-cross/*" -type f -regextype egrep -iregex ".*crt(begin|end|1|i|n)?(S|T)?\.o"
# find /usr/lib/ /lib/ -type f -regextype egrep -iregex ".*crt(begin|end|1|i|n)?(S|T)?\.o" ! -path "*/gcc-cross/*"
# find /usr/lib/ /lib/ -path "*/gcc-cross" -prune -o -type f -regextype egrep -iregex ".*crt(begin|end|1|i|n)?(S|T)?\.o"
# search primary libdir
$ find /usr/lib/ -not \( -path "*/gcc-cross" -prune \) -type f -regextype egrep -iregex ".*crt(begin|end|1|i|n)?(S|T)?\.o"
/usr/lib/gcc/aarch64-linux-gnu/11/crtbegin.o
/usr/lib/gcc/aarch64-linux-gnu/11/crtbeginS.o
/usr/lib/gcc/aarch64-linux-gnu/11/crtendS.o
/usr/lib/gcc/aarch64-linux-gnu/11/crtbeginT.o
/usr/lib/gcc/aarch64-linux-gnu/11/crtend.o
/usr/lib/aarch64-linux-gnu/Mcrt1.o
/usr/lib/aarch64-linux-gnu/Scrt1.o
/usr/lib/aarch64-linux-gnu/crt1.o
/usr/lib/aarch64-linux-gnu/crti.o
/usr/lib/aarch64-linux-gnu/crtn.o
/usr/lib/aarch64-linux-gnu/gcrt1.o
/usr/lib/aarch64-linux-gnu/grcrt1.o
/usr/lib/aarch64-linux-gnu/rcrt1.o
```

---

For gcc-cross compiler arm-linux-gnueabihf, here they are:

```bash
# find /lib/gcc-cross/arm-linux-gnueabihf/11 /usr/lib/gcc-cross/arm-linux-gnueabihf/11 /usr/arm-linux-gnueabihf/lib -type f -regextype egrep -iregex ".*crt(begin|end|1|i|n)?(S|T)?\.o"
# search primary libdir
$ find /usr/lib/gcc-cross/arm-linux-gnueabihf/11 /usr/arm-linux-gnueabihf/lib -type f -regextype egrep -iregex ".*crt(begin|end|1|i|n)?(S|T)?\.o"
/usr/lib/gcc-cross/arm-linux-gnueabihf/11/crtbegin.o
/usr/lib/gcc-cross/arm-linux-gnueabihf/11/crtbeginS.o
/usr/lib/gcc-cross/arm-linux-gnueabihf/11/crtendS.o
/usr/lib/gcc-cross/arm-linux-gnueabihf/11/crtbeginT.o
/usr/lib/gcc-cross/arm-linux-gnueabihf/11/crtend.o
/usr/arm-linux-gnueabihf/lib/Scrt1.o
/usr/arm-linux-gnueabihf/lib/Mcrt1.o
/usr/arm-linux-gnueabihf/lib/gcrt1.o
/usr/arm-linux-gnueabihf/lib/crt1.o
/usr/arm-linux-gnueabihf/lib/crti.o
/usr/arm-linux-gnueabihf/lib/crtn.o
```

#### -lgcc_s -lc

`[-l namespec|--library=namespec]`: Add the archive or object file specified by namespec to the list of files to link.

- `-lgcc`/`-lgcc_s`: link `gcc`
- `-lc`: link `glibc`

[ABI Policy and Guidelines](https://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html) - [Libgcc](https://gcc.gnu.org/onlinedocs/gccint/Libgcc.html)

> GCC provides a low-level runtime library, `libgcc.a` or `libgcc_s.so.1` on some platforms. GCC generates calls to routines in this library automatically, whenever it needs to perform some operation that is too complicated to emit inline code for.

Find out **libgcc** static library(`.a`) and dynamic library(`.so`):

```bash
# rough ls-grep
# ls -l /usr/lib/* /lib/* | grep -iE "libgcc(_s|_eh)?\..*"
# find the most
# find /usr/lib/ /lib/ -type f -iname "libgcc*\.*"
# specify filename pattern
# find /usr/lib/ /lib/ -type f -regextype egrep -iregex ".*libgcc(_s|_eh)?\..*"
# exclude gcc-corss(! = -not)
# find /usr/lib/ /lib/ ! -path "*/gcc-cross/*" -type f -regextype egrep -iregex ".*libgcc(_s|_eh)?\..*"
# find /usr/lib/ /lib/ -type f -regextype egrep -iregex ".*libgcc(_s|_eh)?\..*" ! -path "*/gcc-cross/*"
# find /usr/lib/ /lib/ -path "*/gcc-cross" -prune -o -type f -regextype egrep -iregex ".*libgcc(_s|_eh)?\..*"
# search primary libdir
$ find /usr/lib/ -not \( -path "*/gcc-cross" -prune \) -type f -regextype egrep -iregex ".*libgcc(_s|_eh)?\..*"
/usr/lib/gcc/aarch64-linux-gnu/11/libgcc_s.so
/usr/lib/gcc/aarch64-linux-gnu/11/libgcc_eh.a
/usr/lib/gcc/aarch64-linux-gnu/11/libgcc.a
/usr/lib/aarch64-linux-gnu/libgcc_s.so.1
```

[The GNU C Library](https://www.gnu.org/software/libc/) - [wiki](https://en.wikipedia.org/wiki/Glibc)

- [Documentation for the GNU C Library](https://sourceware.org/glibc/manual/)
- [The GNU C Reference Manual](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html)

GNU C sourceware: [sourceware](https://sourceware.org/glibc/)

- [Release tarballs](https://ftp.gnu.org/gnu/libc/)
- [Sources](https://sourceware.org/glibc/sources.html) - [gitweb](https://sourceware.org/git/?p=glibc.git)
- [git](git://sourceware.org/git/glibc.git) - [Unofficial mirror @github](https://github.com/bminor/glibc)

Find out **glibc** static library(`.a`) and dynamic library(`.so`):

```bash
# rough ls-grep
# ls -l /usr/lib/* /lib/* | grep -iE "libc\..*"
# find the most
# find /usr/lib/ /lib/ -type f -iname "libc\.*"
# specify filename pattern
# find /usr/lib/ /lib/ -type f -regextype egrep -iregex ".*libc\..*"
# find /usr/lib/ /lib/ -type f -regextype egrep -iregex ".*libc\.(a|so)"
# exclude gcc-corss(! = -not)
# find /usr/lib/ /lib/ ! -path "*/python3/*" -type f -regextype egrep -iregex ".*libc\..*"
# find /usr/lib/ /lib/ -type f -regextype egrep -iregex ".*libc\..*" ! -path "*/python3/*"
# find /usr/lib/ /lib/ -path "*/python3" -prune -o -type f -regextype egrep -iregex ".*libc\..*"
# search primary libdir
$ find /usr/lib/ -not \( -path "*/python3" -prune \) -type f -regextype egrep -iregex ".*libc\..*"
/usr/lib/aarch64-linux-gnu/libc.so.6
/usr/lib/aarch64-linux-gnu/libc.a
/usr/lib/aarch64-linux-gnu/libc.so
```

The `ldd` command can print out shared object dependencies, adding `-v` for verbose details.

```bash
$ ldd -v a.out
	linux-vdso.so.1 (0x0000ffff93272000)
	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000ffff93060000)
	/lib/ld-linux-aarch64.so.1 (0x0000ffff93239000)

	Version information:
	./a.out:
		libc.so.6 (GLIBC_2.17) => /lib/aarch64-linux-gnu/libc.so.6
		libc.so.6 (GLIBC_2.34) => /lib/aarch64-linux-gnu/libc.so.6
	/lib/aarch64-linux-gnu/libc.so.6:
		ld-linux-aarch64.so.1 (GLIBC_PRIVATE) => /lib/ld-linux-aarch64.so.1
		ld-linux-aarch64.so.1 (GLIBC_2.17) => /lib/ld-linux-aarch64.so.1
```

Why doesn't it include `libgcc_s.so`? As `--as-needed` indicates, it doesn't need to in our case.

The `libgcc_s.so` usually comes along with `libstdc++.so` when compile C++ code with `g++`.

---

For gcc-cross compiler arm-linux-gnueabihf, here they are:

```bash
# find /lib/gcc-cross/arm-linux-gnueabihf/11 /usr/lib/gcc-cross/arm-linux-gnueabihf/11 /usr/arm-linux-gnueabihf/lib -type f -regextype egrep -iregex ".*libgcc(_s|_eh)?\..*"
# search primary libdir
$ find /usr/lib/gcc-cross/arm-linux-gnueabihf/11 /usr/arm-linux-gnueabihf/lib -type f -regextype egrep -iregex ".*libgcc(_s|_eh)?\..*"
/usr/lib/gcc-cross/arm-linux-gnueabihf/11/libgcc_s.so
/usr/lib/gcc-cross/arm-linux-gnueabihf/11/libgcc_eh.a
/usr/lib/gcc-cross/arm-linux-gnueabihf/11/libgcc.a
/usr/arm-linux-gnueabihf/lib/libgcc_s.so.1

# find /lib/gcc-cross/arm-linux-gnueabihf/11 /usr/lib/gcc-cross/arm-linux-gnueabihf/11 /usr/arm-linux-gnueabihf/lib -type f -regextype egrep -iregex ".*libc\..*"
# search primary libdir
$ find /usr/lib/gcc-cross/arm-linux-gnueabihf/11 /usr/arm-linux-gnueabihf/lib -type f -regextype egrep -iregex ".*libc\..*"
/usr/arm-linux-gnueabihf/lib/libc.so.6
/usr/arm-linux-gnueabihf/lib/libc.a
/usr/arm-linux-gnueabihf/lib/libc.so
```

## outcome ELF

As we didn't give `-o` to specify output filename for the product, the default executable filename is `a.out`.

```bash
-o file
Place the primary output in file file. This applies to whatever sort of output is being produced, whether it be an executable file, an object file, an assembler file or preprocessed C code.

If -o is not specified, the default is to put an executable file in a.out, the object file for source.suffix in source.o, its assembler file in source.s, a precompiled header file in source.suffix.gch, and all preprocessed C source on standard output.
```

### ELF Header

Now, let's check the [ELF](./elf-layout.md) header.

From the output of `file a.out`, we're informed that the ELF is dynamically linked, requires interpreter `/lib/ld-linux-aarch64.so.1` to load and run. The output of `readelf -h` also confirms this point, the Type is `DYN` (Position-Independent Executable file).

```bash
$ file a.out
a.out: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=429e4cbff3d62b27c644cef2b8aaf62d380b9690, for GNU/Linux 3.7.0, not stripped

$ objdump -f a.out

a.out:     file format elf64-littleaarch64
architecture: aarch64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x0000000000000640

$ readelf -h a.out
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Position-Independent Executable file)
  Machine:                           AArch64
  Version:                           0x1
  Entry point address:               0x640
  Start of program headers:          64 (bytes into file)
  Start of section headers:          7080 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         9
  Size of section headers:           64 (bytes)
  Number of section headers:         28
  Section header string table index: 27
```

### program Header

We can also type `readelf -l` to display the information contained in the file's segment headers.

> The section-to-segment listing shows which logical sections lie inside each given segment. For example, here we can see that the `INTERP` segment contains only the `.interp` section.

```bash
$ readelf -lW a.out

Elf file type is DYN (Position-Independent Executable file)
Entry point 0x640
There are 9 program headers, starting at offset 64

Program Headers:
  Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align
  PHDR           0x000040 0x0000000000000040 0x0000000000000040 0x0001f8 0x0001f8 R   0x8
  INTERP         0x000238 0x0000000000000238 0x0000000000000238 0x00001b 0x00001b R   0x1
      [Requesting program interpreter: /lib/ld-linux-aarch64.so.1]
  LOAD           0x000000 0x0000000000000000 0x0000000000000000 0x000894 0x000894 R E 0x10000
  LOAD           0x000d90 0x0000000000010d90 0x0000000000010d90 0x000280 0x000288 RW  0x10000
  DYNAMIC        0x000da0 0x0000000000010da0 0x0000000000010da0 0x0001f0 0x0001f0 RW  0x8
  NOTE           0x000254 0x0000000000000254 0x0000000000000254 0x000044 0x000044 R   0x4
  GNU_EH_FRAME   0x0007a8 0x00000000000007a8 0x00000000000007a8 0x00003c 0x00003c R   0x4
  GNU_STACK      0x000000 0x0000000000000000 0x0000000000000000 0x000000 0x000000 RW  0x10
  GNU_RELRO      0x000d90 0x0000000000010d90 0x0000000000010d90 0x000270 0x000270 R   0x1

 Section to Segment mapping:
  Segment Sections...
   00
   01     .interp
   02     .interp .note.gnu.build-id .note.ABI-tag .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt .text .fini .rodata .eh_frame_hdr .eh_frame
   03     .init_array .fini_array .dynamic .got .data .bss
   04     .dynamic
   05     .note.gnu.build-id .note.ABI-tag
   06     .eh_frame_hdr
   07
   08     .init_array .fini_array .dynamic .got
```

[Blue Fox: Arm Assembly Internals and Reverse Engineering](https://www.amazon.com/Blue-Fox-Assembly-Internals-Analysis/dp/1119745306) | Chapter 2 ELF File Format Internals - ELF Program Headers:

The `INTERP` header is used to tell the operating system that an ELF file needs the help of another program to bring itself into memory. In almost all cases, this program will be the operating system loader file, which in this case is at the path `/lib/ld-linux-aarch64.so.1`.

When a program is executed, the operating system uses this header to load the supporting loader into memory and schedules the *`loader`*, rather than the program itself, as the *initial* target for execution. The use of an external loader is necessary if the program makes use of dynamically linked libraries. The external loader manages the program’s global symbol table, handles connecting binaries together in a process called *`relocation`*, and then eventually calls into the program’s entry point when it is ready.

Since this is the case for virtually all nontrivial programs except the loader itself, almost all programs will use this field to specify the system loader. The `INTERP` header is relevant only to program files themselves; for shared libraries loaded either during initial program load or dynamically during program execution, the value is ignored.

### Entry Point

The starting point of `a.out` can be seen in the output of `objdump -f` and `readelf -h`.

- `objdump -f a.out`: start address 0x0000000000000640
- `readelf -h a.out`: Entry point address: 0x640

We can use `addr2line` to resolve/translate the address to symbol:

```bash
$ addr2line -f -e a.out 0x640
_start
??:?
```

It turns out that symbol `_start` is at address 0x640, which is actually the entry point of the C program.

As the collect2 options show, `_start` is defined in `/usr/lib/aarch64-linux-gnu/Scrt1.o`.

```bash title="objdump -d Scrt1.o"
$ objdump -d /usr/lib/aarch64-linux-gnu/Scrt1.o

/usr/lib/aarch64-linux-gnu/Scrt1.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <_start>:
   0:	d503201f 	nop
   4:	d280001d 	mov	x29, #0x0                   	// #0
   8:	d280001e 	mov	x30, #0x0                   	// #0
   c:	aa0003e5 	mov	x5, x0
  10:	f94003e1 	ldr	x1, [sp]
  14:	910023e2 	add	x2, sp, #0x8
  18:	910003e6 	mov	x6, sp
  1c:	90000000 	adrp	x0, 0 <main>
  20:	f9400000 	ldr	x0, [x0]
  24:	d2800003 	mov	x3, #0x0                   	// #0
  28:	d2800004 	mov	x4, #0x0                   	// #0
  2c:	94000000 	bl	0 <__libc_start_main>
  30:	94000000 	bl	0 <abort>
```

Although, by convention, C and C++ programs “begin” at the `main` function, programs do not actually begin execution here. Instead, they begin execution in a small stub of assembly code, traditionally at the symbol called `_start`. When linking against the standard C runtime, the `_start` function is usually a small stub of code that passes control to the *libc* helper function `__libc_start_main`. This function then prepares the parameters for the program’s `main` function and invokes it. The `main` function then runs the program’s core logic, and if main returns to `__libc_start_main`, the return value of `main` is then passed to `exit` to gracefully exit the program.

### gdb debug

Now just type `gdb a.out` to run the programme `a.out` with GDB. Here I'm using customised `gdb-pwndbg` instead of naked `gdb`, because I've installed the GDB Enhanced Extension [pwndbg](https://github.com/pwndbg/pwndbg).

> related post: [GDB manual & help](../toolchain/gdb/0-gdb-man-help.md) & [GDB Enhanced Extensions](../toolchain/gdb/7-gdb-enhanced.md).

After launched the GDB Console, type `entry` to start the debugged program stopping at its entrypoint address.

!!! note "difference between entry and starti"

    Note that the entrypoint may not be the first instruction executed by the program.
    If you want to stop on the first executed instruction, use the GDB's `starti` command.

It just stops at the entrypoint `_start` as expected:

```bash
$ gdb-pwndbg a.out
Reading symbols from a.out...
(No debugging symbols found in a.out)
pwndbg: loaded 157 pwndbg commands and 47 shell commands. Type pwndbg [--shell | --all] [filter] for a list.
pwndbg: created $rebase, $base, $ida GDB functions (can be used with print/break)
------- tip of the day (disable with set show-tips off) -------
Use the procinfo command for better process introspection (than the GDB's info proc command)
pwndbg> entry
Temporary breakpoint 1 at 0xaaaaaaaa0640
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".

Temporary breakpoint 1, 0x0000aaaaaaaa0640 in _start ()

────────────────────────────────────────[ BACKTRACE ]────────────────────────────────────────
 ► 0   0xaaaaaaaa0640 _start
─────────────────────────────────────────────────────────────────────────────────────────────
```

Then type `b main` to set a breakpoint at the `main()` function, then type `c` to continue.

- Or you can just type `until main` to run until main.

```bash
pwndbg> b main
Breakpoint 3 at 0xaaaaaaaa076c
pwndbg> c
Continuing.

Breakpoint 3, 0x0000aaaaaaaa076c in main ()

────────────────────────────────────────[ BACKTRACE ]────────────────────────────────────────
 ► 0   0xaaaaaaaa076c main+24
   1   0xfffff7e273fc __libc_start_call_main+108
   2   0xfffff7e274cc __libc_start_main+152
   3   0xaaaaaaaa0670 _start+48
─────────────────────────────────────────────────────────────────────────────────────────────
```

Look at the `BACKTRACE` context, it works as designed in `/usr/lib/aarch64-linux-gnu/Scrt1.o`.

Type `info [dll|sharedlibrary]` to show status of loaded shared object libraries.

```bash
pwndbg> info dll
From                To                  Syms Read   Shared Object Library
0x0000fffff7fc3c40  0x0000fffff7fe20a4  Yes         /lib/ld-linux-aarch64.so.1
0x0000fffff7e27040  0x0000fffff7f33090  Yes         /lib/aarch64-linux-gnu/libc.so.6
```

Everything is anticipated, under control.
