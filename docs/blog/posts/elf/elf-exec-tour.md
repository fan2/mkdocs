---
title: EXEC ELF Walkthrough
authors:
    - xman
date:
    created: 2023-06-26T11:00:00
categories:
    - elf
comments: true
---

[Previously](./gcc-compilation-static.md) we've compiled our C demo program with `gcc -static` command.

By passing a `-static` option, we demand GCC to change its default link policy from dynamic to static.

In this article, I'll practice using [GNU binutils](./gnu-binutils.md) to take a close look at the `b.out` product.

<!-- more -->

## ELF Header

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

The output of `objdump -f` shows that the BFD format specific flags are `EXEC_P, HAS_SYMS, D_PAGED`.

## section header

1. `readelf [-S|--section-headers|--sections]`: Display the sections' header.
2. `objdump [-h|--section-headers|--headers]`: Display the contents of the section headers.

=== "readelf -SW b.out"

    ```bash
    $ readelf -SW b.out
    There are 31 section headers, starting at offset 0x9e640:

    Section Headers:
    [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
    [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
    [ 1] .note.gnu.build-id NOTE            0000000000400190 000190 000024 00   A  0   0  4
    [ 2] .note.ABI-tag     NOTE            00000000004001b4 0001b4 000020 00   A  0   0  4
    [ 3] .rela.plt         RELA            00000000004001d8 0001d8 0000a8 18  AI 28  19  8
    [ 4] .init             PROGBITS        0000000000400280 000280 000018 00  AX  0   0  4
    [ 5] .plt              PROGBITS        00000000004002a0 0002a0 000070 00  AX  0   0 16
    [ 6] .text             PROGBITS        0000000000400340 000340 056fb4 00  AX  0   0 64
    [ 7] __libc_freeres_fn PROGBITS        0000000000457300 057300 000b24 00  AX  0   0 16
    [ 8] .fini             PROGBITS        0000000000457e24 057e24 000014 00  AX  0   0  4
    [ 9] .rodata           PROGBITS        0000000000457e40 057e40 01a0d8 00   A  0   0 16
    [10] .stapsdt.base     PROGBITS        0000000000471f18 071f18 000001 00   A  0   0  1
    [11] .eh_frame         PROGBITS        0000000000471f20 071f20 00b984 00   A  0   0  8
    [12] .gcc_except_table PROGBITS        000000000047d8a4 07d8a4 000108 00   A  0   0  1
    [13] .tdata            PROGBITS        000000000048e830 07e830 000020 00 WAT  0   0  8
    [14] .tbss             NOBITS          000000000048e850 07e850 000048 00 WAT  0   0  8
    [15] .init_array       INIT_ARRAY      000000000048e850 07e850 000010 08  WA  0   0  8
    [16] .fini_array       FINI_ARRAY      000000000048e860 07e860 000008 08  WA  0   0  8
    [17] .data.rel.ro      PROGBITS        000000000048e868 07e868 003348 00  WA  0   0  8
    [18] .got              PROGBITS        0000000000491bb0 081bb0 000438 08  WA  0   0  8
    [19] .got.plt          PROGBITS        0000000000491fe8 081fe8 000050 08  WA  0   0  8
    [20] .data             PROGBITS        0000000000492038 082038 001910 00  WA  0   0  8
    [21] __libc_subfreeres PROGBITS        0000000000493948 083948 000048 00 WAR  0   0  8
    [22] __libc_IO_vtables PROGBITS        0000000000493990 083990 000690 00  WA  0   0  8
    [23] __libc_atexit     PROGBITS        0000000000494020 084020 000008 00 WAR  0   0  8
    [24] .bss              NOBITS          0000000000494028 084028 005680 00  WA  0   0  8
    [25] __libc_freeres_ptrs NOBITS          00000000004996a8 084028 000020 00  WA  0   0  8
    [26] .comment          PROGBITS        0000000000000000 084028 00002b 01  MS  0   0  1
    [27] .note.stapsdt     NOTE            0000000000000000 084054 0013a4 00      0   0  4
    [28] .symtab           SYMTAB          0000000000000000 0853f8 012378 18     29 1945  8
    [29] .strtab           STRTAB          0000000000000000 097770 006d86 00      0   0  1
    [30] .shstrtab         STRTAB          0000000000000000 09e4f6 000144 00      0   0  1
    Key to Flags:
    W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
    L (link order), O (extra OS processing required), G (group), T (TLS),
    C (compressed), x (unknown), o (OS specific), E (exclude),
    R (retain), D (mbind), p (processor specific)
    ```

=== "objdump -hw b.out"

    ```bash
    $ objdump -hw b.out

    b.out:     file format elf64-littleaarch64

    Sections:
    Idx Name                Size      VMA               LMA               File off  Algn  Flags
    0 .note.gnu.build-id  00000024  0000000000400190  0000000000400190  00000190  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
    1 .note.ABI-tag       00000020  00000000004001b4  00000000004001b4  000001b4  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
    2 .rela.plt           000000a8  00000000004001d8  00000000004001d8  000001d8  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
    3 .init               00000018  0000000000400280  0000000000400280  00000280  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
    4 .plt                00000070  00000000004002a0  00000000004002a0  000002a0  2**4  CONTENTS, ALLOC, LOAD, READONLY, CODE
    5 .text               00056fb4  0000000000400340  0000000000400340  00000340  2**6  CONTENTS, ALLOC, LOAD, READONLY, CODE
    6 __libc_freeres_fn   00000b24  0000000000457300  0000000000457300  00057300  2**4  CONTENTS, ALLOC, LOAD, READONLY, CODE
    7 .fini               00000014  0000000000457e24  0000000000457e24  00057e24  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
    8 .rodata             0001a0d8  0000000000457e40  0000000000457e40  00057e40  2**4  CONTENTS, ALLOC, LOAD, READONLY, DATA
    9 .stapsdt.base       00000001  0000000000471f18  0000000000471f18  00071f18  2**0  CONTENTS, ALLOC, LOAD, READONLY, DATA
    10 .eh_frame           0000b984  0000000000471f20  0000000000471f20  00071f20  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
    11 .gcc_except_table   00000108  000000000047d8a4  000000000047d8a4  0007d8a4  2**0  CONTENTS, ALLOC, LOAD, READONLY, DATA
    12 .tdata              00000020  000000000048e830  000000000048e830  0007e830  2**3  CONTENTS, ALLOC, LOAD, DATA, THREAD_LOCAL
    13 .tbss               00000048  000000000048e850  000000000048e850  0007e850  2**3  ALLOC, THREAD_LOCAL
    14 .init_array         00000010  000000000048e850  000000000048e850  0007e850  2**3  CONTENTS, ALLOC, LOAD, DATA
    15 .fini_array         00000008  000000000048e860  000000000048e860  0007e860  2**3  CONTENTS, ALLOC, LOAD, DATA
    16 .data.rel.ro        00003348  000000000048e868  000000000048e868  0007e868  2**3  CONTENTS, ALLOC, LOAD, DATA
    17 .got                00000438  0000000000491bb0  0000000000491bb0  00081bb0  2**3  CONTENTS, ALLOC, LOAD, DATA
    18 .got.plt            00000050  0000000000491fe8  0000000000491fe8  00081fe8  2**3  CONTENTS, ALLOC, LOAD, DATA
    19 .data               00001910  0000000000492038  0000000000492038  00082038  2**3  CONTENTS, ALLOC, LOAD, DATA
    20 __libc_subfreeres   00000048  0000000000493948  0000000000493948  00083948  2**3  CONTENTS, ALLOC, LOAD, DATA
    21 __libc_IO_vtables   00000690  0000000000493990  0000000000493990  00083990  2**3  CONTENTS, ALLOC, LOAD, DATA
    22 __libc_atexit       00000008  0000000000494020  0000000000494020  00084020  2**3  CONTENTS, ALLOC, LOAD, DATA
    23 .bss                00005680  0000000000494028  0000000000494028  00084028  2**3  ALLOC
    24 __libc_freeres_ptrs 00000020  00000000004996a8  00000000004996a8  00084028  2**3  ALLOC
    25 .comment            0000002b  0000000000000000  0000000000000000  00084028  2**0  CONTENTS, READONLY
    26 .note.stapsdt       000013a4  0000000000000000  0000000000000000  00084054  2**2  CONTENTS, READONLY
    ```

## symbol table

1. `readelf [-s|--syms|--symbols]`: Displays the entries in symbol table section of the file, if it has one. If a symbol has version information associated with it then this is displayed as well.
2. `objdump [-t|--syms]`: Print the symbol table entries of the file. This is similar to the information provided by the `nm` program, although the display format is different.
3. `nm` - list symbols from object files.

Check it out with any of the above commands, and we will see that `b.out` assembles/links a lot of CRT(C RunTime) and STD(C STanDard Library) object files. It's really verbose, the number of symbol table entries and symbols is almost 40 times more than `a.out`.

I'm not going to paste it in here as it would take up too much space. We can regenerate it whenever we need it.

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

## program Header

We can also type `readelf -l` to display the information contained in the file's segment headers.

> The section-to-segment listing shows which logical sections lie inside each given segment. Unlike DYN, there is no `INTERP` segment, which contains the `.interp` section. But it contains a `TLS` segment, which contains `.tdata` and `.tbss`.
> The last two sections `.comment` and `.note.stapsdt` don't map to any segment.

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

## Entry Point

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

## gdb debug

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
