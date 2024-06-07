---
title: GCC Compilation Quick Tour - dynamic
authors:
    - xman
date:
    created: 2023-06-25T09:00:00
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

## gcc version

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

The demo program is as follows.

```c title="0701.c"
/* Code 07-01, file name: 0701.c */
#include <stdio.h>
int main(int argc, char* argv[])
{
    printf("Hello, Linux!\n");
    return 0;
}
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

### OPTIONS

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

For more information on CRT(C Runtime), please refer to [crtbegin.o vs. crtbeginS.o](https://stackoverflow.com/questions/22160888/what-is-the-difference-between-crtbegin-o-crtbegint-o-and-crtbegins-o), [Mini FAQ about the misc libc/gcc crt files.](https://dev.gentoo.org/~vapier/crt.txt) and [ELF Format Cheatsheet](https://gist.github.com/x0nu11byt3/bcb35c3de461e5fb66173071a2379779) | Sections, Common objects and functions.

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
$ radare2.rabin2 -l a.out
[Linked libraries]
libc.so.6

1 library

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

## outcome

As we didn't give `-o` to specify output filename for the product, the default executable filename is `a.out`.

```bash
-o file
Place the primary output in file file. This applies to whatever sort of output is being produced, whether it be an executable file, an object file, an assembler file or preprocessed C code.

If -o is not specified, the default is to put an executable file in a.out, the object file for source.suffix in source.o, its assembler file in source.s, a precompiled header file in source.suffix.gch, and all preprocessed C source on standard output.
```
