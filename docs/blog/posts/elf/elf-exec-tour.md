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

[Computer Systems - A Programmer's Perspective](https://www.amazon.com/Computer-Systems-OHallaron-Randal-Bryant/dp/1292101768/) | Chapter 7: Linking

- 7.8: Executable Object Files
- 7.9: Loading Executable Object Files

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
3. `size`: Displays the sizes of sections inside binary files.

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

=== "size -Ax b.out"

    ```bash
    $ size -Ax b.out
    b.out  :
    section                  size       addr
    .note.gnu.build-id       0x24   0x400190
    .note.ABI-tag            0x20   0x4001b4
    .rela.plt                0xa8   0x4001d8
    .init                    0x18   0x400280
    .plt                     0x70   0x4002a0
    .text                 0x56fb4   0x400340
    __libc_freeres_fn       0xb24   0x457300
    .fini                    0x14   0x457e24
    .rodata               0x1a0d8   0x457e40
    .stapsdt.base             0x1   0x471f18
    .eh_frame              0xb984   0x471f20
    .gcc_except_table       0x108   0x47d8a4
    .tdata                   0x20   0x48e830
    .tbss                    0x48   0x48e850
    .init_array              0x10   0x48e850
    .fini_array               0x8   0x48e860
    .data.rel.ro           0x3348   0x48e868
    .got                    0x438   0x491bb0
    .got.plt                 0x50   0x491fe8
    .data                  0x1910   0x492038
    __libc_subfreeres        0x48   0x493948
    __libc_IO_vtables       0x690   0x493990
    __libc_atexit             0x8   0x494020
    .bss                   0x5680   0x494028
    __libc_freeres_ptrs      0x20   0x4996a8
    .comment                 0x2b        0x0
    .note.stapsdt          0x13a4        0x0
    Total                 0x89a74
    ```

The code models assume that an executable or shared library use an ELF file layout similar to the diagram below.

[sysvabi64](https://github.com/ARM-software/abi-aa/blob/844a79fd4c77252a11342709e3b27b2c9f590cf1/sysvabi64/sysvabi64.rst) | 7 Code Models - Illustrative ELF file layout

<figure markdown="span">
    ![Illustrative ELF file layout](./images/sysvabi64-elf-layout.svg){: style="width:70%;height:70%"}
    <figcaption>Illustrative ELF file layout</figcaption>
</figure>

### disassemble .plt

Use objdump to disassemble `.plt` section.

```bash
$ objdump -j .plt -d b.out

b.out:     file format elf64-littleaarch64


Disassembly of section .plt:

00000000004002a0 <.plt>:
  4002a0:	d0000490 	adrp	x16, 492000 <.got.plt+0x18>
  4002a4:	f9400211 	ldr	x17, [x16]
  4002a8:	91000210 	add	x16, x16, #0x0
  4002ac:	d61f0220 	br	x17
  4002b0:	d0000490 	adrp	x16, 492000 <.got.plt+0x18>
  4002b4:	f9400611 	ldr	x17, [x16, #8]
  4002b8:	91002210 	add	x16, x16, #0x8
  4002bc:	d61f0220 	br	x17
  4002c0:	d0000490 	adrp	x16, 492000 <.got.plt+0x18>
  4002c4:	f9400a11 	ldr	x17, [x16, #16]
  4002c8:	91004210 	add	x16, x16, #0x10
  4002cc:	d61f0220 	br	x17
  4002d0:	d0000490 	adrp	x16, 492000 <.got.plt+0x18>
  4002d4:	f9400e11 	ldr	x17, [x16, #24]
  4002d8:	91006210 	add	x16, x16, #0x18
  4002dc:	d61f0220 	br	x17
  4002e0:	d0000490 	adrp	x16, 492000 <.got.plt+0x18>
  4002e4:	f9401211 	ldr	x17, [x16, #32]
  4002e8:	91008210 	add	x16, x16, #0x20
  4002ec:	d61f0220 	br	x17
  4002f0:	d0000490 	adrp	x16, 492000 <.got.plt+0x18>
  4002f4:	f9401611 	ldr	x17, [x16, #40]
  4002f8:	9100a210 	add	x16, x16, #0x28
  4002fc:	d61f0220 	br	x17
  400300:	d0000490 	adrp	x16, 492000 <.got.plt+0x18>
  400304:	f9401a11 	ldr	x17, [x16, #48]
  400308:	9100c210 	add	x16, x16, #0x30
  40030c:	d61f0220 	br	x17
```

### relocations

`readelf [-r|--relocs]`: display the relocations.

```bash
$ readelf -r b.out

Relocation section '.rela.plt' at offset 0x1d8 contains 7 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000492000  000000000408 R_AARCH64_IRELATI                    4161d0
000000492008  000000000408 R_AARCH64_IRELATI                    4165e0
000000492010  000000000408 R_AARCH64_IRELATI                    4390c0
000000492018  000000000408 R_AARCH64_IRELATI                    416310
000000492020  000000000408 R_AARCH64_IRELATI                    415650
000000492028  000000000408 R_AARCH64_IRELATI                    4390c0
000000492030  000000000408 R_AARCH64_IRELATI                    415650
```

The relocation type is `R_AARCH64_IRELATIVE` defined in /usr/include/elf.h:

```c
#define R_AARCH64_IRELATIVE     1032 /* 0x408: STT_GNU_IFUNC relocation.  */
```

### .got & .got.plt

[sysvabi64](https://github.com/ARM-software/abi-aa/blob/844a79fd4c77252a11342709e3b27b2c9f590cf1/sysvabi64/sysvabi64.rst) | 9 Program Loading and Dynamic Linking

**9.1 Dynamic Section**

The generic tag `DT_PLTGOT` has a processor specific implementation. On AArch64 it is defined to be the address of the `.got.plt` section.

**9.2 Global Offset Table**

AArch64 splits the global offset table (GOT) into two sections:

- `.got.plt` for code addresses accessed only from the Procedure Linkage Table (PLT).
- `.got` all other addresses and offsets.

The difference is that `.got.plt` is runtime-writable, while `.got` is not if you enable a defense against GOT overwriting attacks called `RELRO` (relocations read-only). To enable `RELRO`, you use the ld option `-z relro`. `RELRO` places `GOT` entries that must be runtime-writable for *lazy binding* in `.got.plt`, and all others in the read-only `.got` section.

BTW, `.plt` is a code section that contains executable code, just like `.text`, while both `.got` and `.got.plt` are data section.

Hexdump `.got` and `.got.plt`:

```bash
# hexdump .got
$ got_offset=$(objdump -hw b.out | awk '/.got/ && !/.got.plt/ {print "0x"$6}')
$ got_size=$(objdump -hw b.out | awk '/.got/ && !/.got.plt/ {print "0x"$3}')
$ hexdump -v -s $got_offset -n $got_size -e '"%_ad\t" /8 "%016x\t" "\n"' b.out \
| awk 'BEGIN{print "Offset\t\tAddress\t\t\t\tValue"} \
{printf("%08x\t", $1); printf("%016x\t", $1+65536); print $2}'

[...snip...]

# hexdump .got.plt
$ gotplt_offset=$(objdump -hw b.out | awk '/.got.plt/{print "0x"$6}')
$ gotplt_size=$(objdump -hw b.out | awk '/.got.plt/{print "0x"$3}')
$ hhexdump -v -s $gotplt_offset -n $gotplt_size -e '"%_ad\t" /8 "%016x\t" "\n"' b.out \
| awk 'BEGIN{print "Offset\t\tAddress\t\t\t\tValue"} \
{printf("%08x\t", $1); printf("%016x\t", $1+65536); print $2}'
Offset		Address				Value
00081fe8	0000000000091fe8	0000000000000000
00081ff0	0000000000091ff0	0000000000000000
00081ff8	0000000000091ff8	0000000000000000
00082000	0000000000092000	00000000004002a0
00082008	0000000000092008	00000000004002a0
00082010	0000000000092010	00000000004002a0
00082018	0000000000092018	00000000004002a0
00082020	0000000000092020	00000000004002a0
00082028	0000000000092028	00000000004002a0
00082030	0000000000092030	00000000004002a0
```

From the fourth to the last entries of `.got.plt` are initialized with `00000000004002a0`, which represents the *first* PLT stub(PLT[0], PLT header) of the `.plt` section in segment.LOAD0.

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

If you are an old hand at C programming, you are probably familiar with the `.o` file names listed above. Almost every `.o` file has a corresponding C library function. You've probably guessed where they come from. Yes, they're extracted from `libc.a` and copied into the final executable ELF.

An archive is a single file holding a collection of other files in a structure that makes it possible to retrieve the original individual files (called members of the archive). A static library such as `libc.a` is actually just a package of all `.o` files.

The GNU [ar](https://man7.org/linux/man-pages/man1/ar.1.html) program creates, modifies, and extracts from archives.

`ar t`: Display a table listing the contents of archive, or those of the files listed in `member`... that are present in the archive.

```bash
# the entire content of libc.a is lengthy and verbose
# ar t /usr/arm-linux-gnueabihf/lib/libc.a
# filter members prefixed with "str"
$ ar t /usr/arm-linux-gnueabihf/lib/libc.a | egrep "^str(cmp|cpy|len|str)"
strcmp.o
strcpy.o
strlen.o
strstr.o
strcpy_chk.o

# specify member "strlen.o"
$ ar t /usr/arm-linux-gnueabihf/lib/libc.a strlen.o
strlen.o
```

`ar x`: Extract members (named member) from the archive.

```bash
# extract strcpy.o into output dir
$ ar x /usr/arm-linux-gnueabihf/lib/libc.a strcpy.o --output ~/Downloads
```

On the other hand, we can call `nm` to view the index information in the archive file.

> `[-s|--print-armap]`: When listing symbols from archive members, include the index: a mapping (stored in the archive by `ar` or `ranlib`) of which modules contain definitions for which names.

```bash
$ nm -s /usr/arm-linux-gnueabihf/lib/libc.a

strcpy.o:
00000000 T __stpcpy
00000000 W stpcpy
00000010 T strcpy

strlen.o:
00000000 T strlen

strstr.o:
         U _GLOBAL_OFFSET_TABLE_
         U memcmp
         U memset
         U __stack_chk_fail
         U __stack_chk_guard
         U strchr
         U strlen
         U __strnlen
0000031c T strstr
00000000 t two_way_long_needle

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

```bash
$ objdump --start-address=0x400580 --stop-address=$((0x400580+48)) -d b.out

b.out:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000400580 <_start>:
  400580:	d503201f 	nop
  400584:	d280001d 	mov	x29, #0x0                   	// #0
  400588:	d280001e 	mov	x30, #0x0                   	// #0
  40058c:	aa0003e5 	mov	x5, x0
  400590:	f94003e1 	ldr	x1, [sp]
  400594:	910023e2 	add	x2, sp, #0x8
  400598:	910003e6 	mov	x6, sp
  40059c:	90000000 	adrp	x0, 400000 <__ehdr_start>
  4005a0:	9116d000 	add	x0, x0, #0x5b4
  4005a4:	d2800003 	mov	x3, #0x0                   	// #0
  4005a8:	d2800004 	mov	x4, #0x0                   	// #0
  4005ac:	9400008d 	bl	4007e0 <__libc_start_main>
```

As the collect2 options show, `_start` is actually provided by `/usr/lib/aarch64-linux-gnu/crt1.o`.

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

Although, by convention, C and C++ programs “begin” at the `main` function, programs do not actually begin execution here. Instead, they begin execution in a small stub of assembly code, traditionally at the symbol called `_start`. When linking against the standard C runtime, the `_start` function is usually a small stub of code that passes control to the *libc* helper function `__libc_start_main`. This function then prepares the parameters for the program's `main` function and invokes it. The `main` function then runs the program's core logic, and if main returns to `__libc_start_main`, the return value of `main` is then passed to `exit` to gracefully exit the program.

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
