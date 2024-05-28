---
title: GCC Compilation Quick Tour - static
authors:
    - xman
date:
    created: 2023-06-17T11:00:00
categories:
    - elf
comments: true
---

Previously, we've taken a look at the basic compilation of C programs using GCC. It links dynamically by default.

In this article, we simply add a `-static` option to GCC to change its default link policy from dynamic to static.

We then go on to make a basic comparison of the processes and products of dynamic linking and static linking.

<!-- more -->

---

When compiling links with gcc, dynamic linking is used by default. There are two ways to specify static linking:

1. use the `-static` option to enable full static linking.
2. use the `-Wl,-Bstatic`, `-Wl,-Bdynamic` options to switch some libraries to be linked statically.

> refer to [gcc 全静态链接](https://www.cnblogs.com/motadou/p/4471088.html)，[Q: linker "-static" flag usage](https://gcc.gnu.org/legacy-ml/gcc/2000-05/msg00517.html)。

GCC [Link Options](https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html) provide some switches:

- -static
- -static-libgcc
- -static-libstdc++

## gcc -static

We can compile with option `-static` to create a static executable:

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

### COLLECT_GCC_OPTIONS

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

## outcome ELF

As we give `-o` to specify output filename for the product, the outcome executable filename is `b.out`.

As per the `-static` link policy, it will assemble glibc(`libc.a`) into the final product `b.out`.

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

Check SYMBOL TABLE with `readelf -s` or `objdump -t`/`objdump -x` and we can see that `b.out` assembles/links a lot of CRT(C RunTime) and STD(C STanDard Library) implementation object files.

```bash
$ objdump -t b.out

b.out:     file format elf64-littleaarch64

SYMBOL TABLE:

[...snip...]

0000000000000000 l    df *ABS*	0000000000000000 crt1.o
0000000000000000 l    df *ABS*	0000000000000000 crti.o
0000000000000000 l    df *ABS*	0000000000000000 crtn.o
0000000000000000 l    df *ABS*	0000000000000000 exit.o
0000000000000000 l    df *ABS*	0000000000000000 cxa_atexit.o

[...snip...]

0000000000000000 l    df *ABS*	0000000000000000 stdio.o
0000000000000000 l    df *ABS*	0000000000000000 strcmp.o
0000000000000000 l    df *ABS*	0000000000000000 strcpy.o
0000000000000000 l    df *ABS*	0000000000000000 strlen.o
0000000000000000 l    df *ABS*	0000000000000000 strncmp.o
0000000000000000 l    df *ABS*	0000000000000000 strstr.o
0000000000000000 l    df *ABS*	0000000000000000 qsort.o

[...snip...]

```

### ELF Header

Now, let's check the [ELF](./elf-layout.md) header.

From the output of `file b.out`, we're informed that the ELF is statically linked, doesn't require interpreter like `/lib/ld-linux-aarch64.so.1`. The output of `readelf -h` also confirms this point, the Type is `EXEC` (Executable file).

```bash
$ file b.out
b.out: ELF 64-bit LSB executable, ARM aarch64, version 1 (GNU/Linux), statically linked, BuildID[sha1]=d07e249ba4213f0123c940c5cb1f068b9b2822e9, for GNU/Linux 3.7.0, not stripped

$ objdump -f b.out

b.out:     file format elf64-littleaarch64
architecture: aarch64, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x0000000000400580

$ readelf -h b.out
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 03 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - GNU
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           AArch64
  Version:                           0x1
  Entry point address:               0x400580
  Start of program headers:          64 (bytes into file)
  Start of section headers:          648768 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         6
  Size of section headers:           64 (bytes)
  Number of section headers:         31
  Section header string table index: 30
```

### program Header

We can also type `readelf -l` to display the information contained in the file's segment headers.

> The section-to-segment listing shows which logical sections lie inside each given segment. Unlike DYN, there is no `INTERP` segment, which contains the `.interp` section. But it contains a `TLS` segment, which contains `.tdata` and `.tbss`.

```bash
$ readelf -lW b.out

Elf file type is EXEC (Executable file)
Entry point 0x400580
There are 6 program headers, starting at offset 64

Program Headers:
  Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align
  LOAD           0x000000 0x0000000000400000 0x0000000000400000 0x07d9ac 0x07d9ac R E 0x10000
  LOAD           0x07e830 0x000000000048e830 0x000000000048e830 0x0057f8 0x00ae98 RW  0x10000
  NOTE           0x000190 0x0000000000400190 0x0000000000400190 0x000044 0x000044 R   0x4
  TLS            0x07e830 0x000000000048e830 0x000000000048e830 0x000020 0x000068 R   0x8
  GNU_STACK      0x000000 0x0000000000000000 0x0000000000000000 0x000000 0x000000 RW  0x10
  GNU_RELRO      0x07e830 0x000000000048e830 0x000000000048e830 0x0037d0 0x0037d0 R   0x1

 Section to Segment mapping:
  Segment Sections...
   00     .note.gnu.build-id .note.ABI-tag .rela.plt .init .plt .text __libc_freeres_fn .fini .rodata .stapsdt.base .eh_frame .gcc_except_table
   01     .tdata .init_array .fini_array .data.rel.ro .got .got.plt .data __libc_subfreeres __libc_IO_vtables __libc_atexit .bss __libc_freeres_ptrs
   02     .note.gnu.build-id .note.ABI-tag
   03     .tdata .tbss
   04
   05     .tdata .init_array .fini_array .data.rel.ro .got
```

### Entry Point

The starting point of `b.out` can be seen in the output of `objdump -f` and `readelf -h`.

- `objdump -f b.out`: start address 0x0000000000400580
- `readelf -h b.out`: Entry point address: 0x400580

We can use `addr2line` to resolve/translate the address to symbol:

```bash
$ addr2line -f -e b.out 0x400580
_start
??:?
```

Unsurprisingly, it turns out that symbol `_start` is actually the entry point of the C program.

As the collect2 options show, `_start` is defined in `/usr/lib/aarch64-linux-gnu/crt1.o`.

```bash title="objdump -d crt1.o"
$ objdump -d /usr/lib/aarch64-linux-gnu/crt1.o

/usr/lib/aarch64-linux-gnu/crt1.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <_start>:
   0:	d503201f 	nop
   4:	d280001d 	mov	x29, #0x0                   	// #0
   8:	d280001e 	mov	x30, #0x0                   	// #0
   c:	aa0003e5 	mov	x5, x0
  10:	f94003e1 	ldr	x1, [sp]
  14:	910023e2 	add	x2, sp, #0x8
  18:	910003e6 	mov	x6, sp
  1c:	90000000 	adrp	x0, 0 <_start>
  20:	91000000 	add	x0, x0, #0x0
  24:	d2800003 	mov	x3, #0x0                   	// #0
  28:	d2800004 	mov	x4, #0x0                   	// #0
  2c:	94000000 	bl	0 <__libc_start_main>
  30:	94000000 	bl	0 <abort>

0000000000000034 <__wrap_main>:
  34:	d503201f 	nop
  38:	14000000 	b	0 <main>
  3c:	d503201f 	nop

0000000000000040 <_dl_relocate_static_pie>:
  40:	d65f03c0 	ret
```

Although, by convention, C and C++ programs “begin” at the `main` function, programs do not actually begin execution here. Instead, they begin execution in a small stub of assembly code, traditionally at the symbol called `_start`. When linking against the standard C runtime, the `_start` function is usually a small stub of code that passes control to the *libc* helper function `__libc_start_main`. This function then prepares the parameters for the program’s `main` function and invokes it. The `main` function then runs the program’s core logic, and if main returns to `__libc_start_main`, the return value of `main` is then passed to `exit` to gracefully exit the program.

### gdb debug

Now just type `gdb b.out` to run the programme `b.out` with GDB. Here I'm using customised `gdb-pwndbg` instead of naked `gdb`, because I've installed the GDB Enhanced Extension [pwndbg](https://github.com/pwndbg/pwndbg).

> related post: [GDB manual & help](../toolchain/gdb/0-gdb-man-help.md) & [GDB Enhanced Extensions](../toolchain/gdb/7-gdb-enhanced.md).

After launched the GDB Console, type `entry` to start the debugged program stopping at its entrypoint address.

!!! note "difference between entry and starti"

    Note that the entrypoint may not be the first instruction executed by the program.
    If you want to stop on the first executed instruction, use the GDB's `starti` command.

It just stops at the entrypoint `_start` as expected:

```bash
$ gdb-pwndbg b.out
Reading symbols from b.out...
(No debugging symbols found in b.out)
pwndbg: loaded 157 pwndbg commands and 47 shell commands. Type pwndbg [--shell | --all] [filter] for a list.
pwndbg: created $rebase, $base, $ida GDB functions (can be used with print/break)
------- tip of the day (disable with set show-tips off) -------
Use GDB's dprintf command to print all calls to given function. E.g. dprintf malloc, "malloc(%p)\n", (void*)$rdi will print all malloc calls
pwndbg> entry
Temporary breakpoint 1 at 0x400580

Temporary breakpoint 1, 0x0000000000400580 in _start ()

───────────────────────────────────────────────[ BACKTRACE ]────────────────────────────────────────────────
 ► 0         0x400580 _start
────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Then type `b main` to set a breakpoint at the `main()` function, then type `c` to continue.

```bash
pwndbg> b main
Breakpoint 2 at 0x4006ec
pwndbg> i b
Num     Type           Disp Enb Address            What
2       breakpoint     keep y   0x00000000004006ec <main+24>
pwndbg> c
Continuing.

Breakpoint 2, 0x00000000004006ec in main ()

───────────────────────────────────────────────[ BACKTRACE ]────────────────────────────────────────────────
 ► 0         0x4006ec main+24
   1         0x4007a4 __libc_start_call_main+84
   2         0x400b24 __libc_start_main_impl+836
   3         0x4005b0 _start+48
────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Look at the `BACKTRACE` context, it works as designed in `/usr/lib/aarch64-linux-gnu/crt1.o`.

Type `info [dll|sharedlibrary]` to show status of loaded shared object libraries.

```bash
pwndbg> info dll
No shared libraries loaded at this time.
```

Everything is anticipated, under control.
