---
title: GCC Compilation Quick Tour - static
authors:
    - xman
date:
    created: 2023-06-26T09:00:00
categories:
    - elf
comments: true
---

[Previously](./gcc-compilation-dynamic.md), we've taken a look at the basic compilation of C programs using GCC. It links dynamically by default.

In this article, we simply add a `-static` option to GCC to change its default link policy from dynamic to static.

We then go on to make a basic comparison of the processes of dynamic linking and static linking.

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

## gcc -static

When compiling links with gcc, dynamic linking is used by default. There are two ways to specify static linking:

1. use the `-static` option to enable full static linking.
2. use the `-Wl,-Bstatic`, `-Wl,-Bdynamic` options to switch some libraries to be linked statically.

> refer to [gcc 全静态链接](https://www.cnblogs.com/motadou/p/4471088.html)，[Q: linker "-static" flag usage](https://gcc.gnu.org/legacy-ml/gcc/2000-05/msg00517.html)。

GCC [Link Options](https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html) provide some switches:

- -static
- -static-libgcc
- -static-libstdc++

Add option `-static` to `gcc` to create a static executable:

```bash
$ gcc -v 0701.c -static -o b.out
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/lib/gcc/aarch64-linux-gnu/11/lto-wrapper
Target: aarch64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu 11.4.0-1ubuntu1~22.04' --with-bugurl=file:///usr/share/doc/gcc-11/README.Bugs --enable-languages=c,ada,c++,go,d,fortran,objc,obj-c++,m2 --prefix=/usr --with-gcc-major-version-only --program-suffix=-11 --program-prefix=aarch64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --enable-bootstrap --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-libquadmath --disable-libquadmath-support --enable-plugin --enable-default-pie --with-system-zlib --enable-libphobos-checking=release --with-target-system-zlib=auto --enable-objc-gc=auto --enable-multiarch --enable-fix-cortex-a53-843419 --disable-werror --enable-checking=release --build=aarch64-linux-gnu --host=aarch64-linux-gnu --target=aarch64-linux-gnu --with-build-config=bootstrap-lto-lean --enable-link-serialization=2
Thread model: posix
Supported LTO compression algorithms: zlib zstd
gcc version 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04)
COLLECT_GCC_OPTIONS='-v' '-static' '-o' 'b.out' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'b.out-'
 /usr/lib/gcc/aarch64-linux-gnu/11/cc1 -quiet -v -imultiarch aarch64-linux-gnu 0701.c -quiet -dumpdir b.out- -dumpbase 0701.c -dumpbase-ext .c -mlittle-endian -mabi=lp64 -version -fasynchronous-unwind-tables -fstack-protector-strong -Wformat -Wformat-security -fstack-clash-protection -o /tmp/cc27y9pj.s
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
COLLECT_GCC_OPTIONS='-v' '-static' '-o' 'b.out' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'b.out-'
 as -v -EL -mabi=lp64 -o /tmp/ccLYABaR.o /tmp/cc27y9pj.s
GNU assembler version 2.38 (aarch64-linux-gnu) using BFD version (GNU Binutils for Ubuntu) 2.38
COMPILER_PATH=/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/:/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/
LIBRARY_PATH=/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../../lib/:/lib/aarch64-linux-gnu/:/lib/../lib/:/usr/lib/aarch64-linux-gnu/:/usr/lib/../lib/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../:/lib/:/usr/lib/
COLLECT_GCC_OPTIONS='-v' '-static' '-o' 'b.out' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'b.out.'
 /usr/lib/gcc/aarch64-linux-gnu/11/collect2 -plugin /usr/lib/gcc/aarch64-linux-gnu/11/liblto_plugin.so -plugin-opt=/usr/lib/gcc/aarch64-linux-gnu/11/lto-wrapper -plugin-opt=-fresolution=/tmp/ccCXXMyi.res -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_eh -plugin-opt=-pass-through=-lc --build-id --hash-style=gnu --as-needed -Bstatic -X -EL -maarch64linux --fix-cortex-a53-843419 -z relro -o b.out /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/crt1.o /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/crti.o /usr/lib/gcc/aarch64-linux-gnu/11/crtbeginT.o -L/usr/lib/gcc/aarch64-linux-gnu/11 -L/usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu -L/usr/lib/gcc/aarch64-linux-gnu/11/../../../../lib -L/lib/aarch64-linux-gnu -L/lib/../lib -L/usr/lib/aarch64-linux-gnu -L/usr/lib/../lib -L/usr/lib/gcc/aarch64-linux-gnu/11/../../.. /tmp/ccLYABaR.o --start-group -lgcc -lgcc_eh -lc --end-group /usr/lib/gcc/aarch64-linux-gnu/11/crtend.o /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/crtn.o
COLLECT_GCC_OPTIONS='-v' '-static' '-o' 'b.out' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'b.out.'
```

### configure

The configuration of autoconf is almost the same as default dynamic link.

### OPTIONS

Nothing more than the default except an additional manually formulated option `-static`.

### collect2

=== "gcc -static"

    ```bash
    /usr/lib/gcc/aarch64-linux-gnu/11/collect2 -plugin /usr/lib/gcc/aarch64-linux-gnu/11/liblto_plugin.so -plugin-opt=/usr/lib/gcc/aarch64-linux-gnu/11/lto-wrapper -plugin-opt=-fresolution=/tmp/ccCXXMyi.res -plugin-opt=-pass-through=-lgcc

    -plugin-opt=-pass-through=-lgcc_eh
    -plugin-opt=-pass-through=-lc
    --build-id --hash-style=gnu --as-needed -Bstatic

    -X -EL -maarch64linux --fix-cortex-a53-843419 -z relro -o b.out

    /usr/lib/aarch64-linux-gnu/crt1.o
    /usr/lib/aarch64-linux-gnu/crti.o
    /usr/lib/gcc/aarch64-linux-gnu/11/crtbeginT.o

    /tmp/ccLYABaR.o

    --start-group -lgcc -lgcc_eh -lc --end-group
    /usr/lib/gcc/aarch64-linux-gnu/11/crtend.o
    /usr/lib/aarch64-linux-gnu/crtn.o
    COLLECT_GCC_OPTIONS='-v' '-static' '-o' 'b.out' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'b.out.'
    ```

=== "gcc dynamic"

    ```bash
    /usr/lib/gcc/aarch64-linux-gnu/11/collect2 -plugin /usr/lib/gcc/aarch64-linux-gnu/11/liblto_plugin.so -plugin-opt=/usr/lib/gcc/aarch64-linux-gnu/11/lto-wrapper -plugin-opt=-fresolution=/tmp/ccyiqbzK.res -plugin-opt=-pass-through=-lgcc

    -plugin-opt=-pass-through=-lgcc_s
    -plugin-opt=-pass-through=-lc
    -plugin-opt=-pass-through=-lgcc
    -plugin-opt=-pass-through=-lgcc_s
    --build-id --eh-frame-hdr --hash-style=gnu --as-needed
    -dynamic-linker /lib/ld-linux-aarch64.so.1

    -X -EL -maarch64linux --fix-cortex-a53-843419 -pie -z now -z relro

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
    COLLECT_GCC_OPTIONS='-v' '-mlittle-endian' '-mabi=lp64' '-dumpdir' 'a.'
    ```

Here are a few of the notable points of difference:

1. gcc: `-lgcc_s` for dynamic, `-lgcc_eh` for static;
2. dynamic: `--eh-frame-hdr`, `-dynamic-linker`; static: `-Bstatic`;
3. dynamic exclusive: `-pie -z now`

#### CRT object

Both `gcc` and `gcc -static` use the same pair of crti/crtn.

- /usr/lib/aarch64-linux-gnu/**`crti.o`**|**`crtn.o`**: Defines the function *prologs*/*epilogs* for the `.init`/`.fini` sections.

However, the version of crt1, crtbegin/crtend is different.

=== "CRT object for static"

    - /usr/lib/aarch64-linux-gnu/**`crt1.o`**: This object is expected to contain the `_start` symbol which takes care of bootstrapping the initial execution of the program.
    - /usr/lib/gcc/aarch64-linux-gnu/11/**`crtbeginT.o`**: Used in place of `crtbegin.o` when generating static executables.
    - /usr/lib/gcc/aarch64-linux-gnu/11/**`crtend.o`**: GCC uses this to find the start of the destructors.

=== "CRT object for dynamic"

    - /usr/lib/aarch64-linux-gnu/**`Scrt1.o`**: Used in place of `crt1.o` when generating PIEs.
    - /usr/lib/gcc/aarch64-linux-gnu/11/**`crtbeginS.o`**: Used in place of `crtbegin.o` when generating shared objects/PIEs.
    - /usr/lib/gcc/aarch64-linux-gnu/11/**`crtendS.o`**: Used in place of `crtend.o` when generating shared objects/PIEs.

It's obvious that the prefix/suffix capital "`S`" `stands for "Shared".

Previously, we've explored the CRT object files in [GCC Compilation Quick Tour - dynamic](./gcc-compilation-dynamic.md).

```bash
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

#### -lgcc_eh -lc

`[-l namespec|--library=namespec]`: Add the archive or object file specified by namespec to the list of files to link.

- `-lgcc`/`-lgcc_eh`: link `gcc`
- `-lc`: link `glibc`

Previously, we've explored the libgcc and glibc libraries in [GCC Compilation Quick Tour - dynamic](./gcc-compilation-dynamic.md).

```bash
$ find /usr/lib/ -not \( -path "*/gcc-cross" -prune \) -type f -regextype egrep -iregex ".*libgcc(_s|_eh)?\..*"
/usr/lib/gcc/aarch64-linux-gnu/11/libgcc_s.so
/usr/lib/gcc/aarch64-linux-gnu/11/libgcc_eh.a
/usr/lib/gcc/aarch64-linux-gnu/11/libgcc.a
/usr/lib/aarch64-linux-gnu/libgcc_s.so.1

$ find /usr/lib/ -not \( -path "*/python3" -prune \) -type f -regextype egrep -iregex ".*libc\..*"
/usr/lib/aarch64-linux-gnu/libc.so.6
/usr/lib/aarch64-linux-gnu/libc.a
/usr/lib/aarch64-linux-gnu/libc.so
```

The `ldd` command can print out shared object dependencies, adding `-v` for verbose details.

```bash
$ ldd -v b.out
	not a dynamic executable
```

---

When linking dynamically, we can guess from the name `-lgcc_s` / `libgcc_s.so` that the suffix `_s` means "shared". But what does the suffix `_eh` in `libgcc_eh.a` mean?

[tech-pkg: Re: What does libgcc_eh.a do?](https://mail-index.netbsd.org/tech-pkg/2003/06/26/0004.html)

"eh" - sounds like exception handling (C++/Java support) to me.

[Why does static-gnulib include -lgcc_eh?](https://libc-help.sourceware.narkive.com/gQzN0OOU/why-does-static-gnulib-include-lgcc-eh)
[Avoid use of libgcc_s and libgcc_eh when building glibc](https://sourceware.org/pipermail/libc-alpha/2012-August/033505.html)
[Why are libgcc.a and libgcc_eh.a compiled with -fvisibility=hidden?](https://gcc.gcc.gnu.narkive.com/1pzMObWC/why-are-lib-a-and-lib-eh-a-compiled-with-fvisibility-hidden) - [H.J. Lu - Re](https://gcc.gnu.org/legacy-ml/gcc/2012-03/msg00106.html)

The reason why `libgcc_eh.a` is split from `libgcc.a` is that the unwinder really should be just one in the whole process, especially when one had to register shared libraries/binaries with the unwinder it was very important. So, `libgcc_eh.a` is meant for `-static` linking only, where you really can't link `libgcc_s.so.1`, for all other uses of the unwinder you really should link the shared `libgcc_s.so.1` instead. Note e.g. glibc internally dlopens `libgcc_s.so.1`.

[Richard Henderson - Re: RFC: Always build libgcc_eh.a](https://gcc.gnu.org/legacy-ml/gcc-patches/2005-02/msg00541.html)

In the `--enable-shared` configuration we have:

- `libgcc.a`: Support routines, not including EH
- `libgcc_eh.a`: EH(Exception Handling) support routines
- `libgcc_s.so`: Support routines, including EH

In the `--disable-shared` configuration we have:

- `libgcc.a`: That's all you get, folks - all routines

[Restore exclusion of "gcc_eh" from implicit link libraries (!1460) · Merge requests](https://gitlab.kitware.com/cmake/cmake/-/merge_requests/1460)

That's only partially true: Whether `libgcc_eh` or `libgcc_s` is used depends on `-static-libgcc` parameter. `libgcc_s` should be a shared object and is fine to link then. `libgcc_eh` on the other hand is the *exception handling* part split off from `libgcc` and is always a *static* library. Linking `libgcc_eh` into a shared library would be an issue, but it only appears if `-static` or `-static-libgcc` is being used.

## outcome

When the link editor processes an archive library, it extracts library members and copies them into the output object file. These statically linked services are available during execution without involving the dynamic linker.

As we give `-o` to specify output filename for the product, the outcome executable filename is `b.out`. As per the `-static` link policy, it will assemble glibc(`libc.a`) into the final product `b.out`.

`b.out` swells macroscopically and enormously in size in contrast to `a.out`.

```bash
$ ls -l .
-rw-rw-r-- 1 pifan pifan    137  5月 27 17:56 0701.c
-rwxrwxr-x 1 pifan pifan   8872  5月 27 21:47 a.out
-rwxrwxr-x 1 pifan pifan 650752  5月 27 22:20 b.out

$ ls -hl .
-rw-rw-r-- 1 pifan pifan  137  5月 27 17:56 0701.c
-rwxrwxr-x 1 pifan pifan 8.7K  5月 28 11:39 a.out
-rwxrwxr-x 1 pifan pifan 636K  5月 27 22:20 b.out
```
