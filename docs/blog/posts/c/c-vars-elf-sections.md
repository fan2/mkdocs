---
title: C variables representation in ELF 1 - Sections
authors:
    - xman
date:
    created: 2023-10-18T10:00:00
categories:
    - c
    - elf
comments: true
---

Previously, we've used `gcc -S` to stop assembling and `gcc -c` to stop linking, and explored C variables representation in [assembly(gcc -S)](./c-vars-gcc-S.md) and [object(gcc -c)](./c-vars-gcc-c.md).

The symbols in the intermediate object file (vars-section.o) are waiting to be relocated and resolved to determine their actual virtual address. It's the linker's turn.

After linking, all object files (*.o) are [linked](../elf/gcc-compilation-dynamic.md) into one [ELF](../elf/elf-layout.md). By default, it links dynamically and the type of outcome is [DYN](../elf/elf-dyn-tour.md) (position-independent executable file).

<!-- more -->

```c title="vars-section.c" linenums="1"
#include <stdio.h>
#include <string.h>

int i;
short j = 2;
long k = 0;

static int l;
static short m = 5;
static long n = 0;

char *str1 = "hello";
static char *str2 = "world";

void func()
{
    static long o;
    static short p = 3;
    static int q = 0;

    int r = 4;
    int ia[4] = {2,0,4,8};
    int s = 5;
    int t;
    char ca[] = "hello";

    printf("func global static: ijk = %ld\n", i+j+k);
    printf("func locals: r+s=%d, ia[3]=%d, ca=%s\n", r+s, ia[3], ca);
    printf("func local static: o++=%ld, ++p=%hd, q++=%d\n", o++, ++p, q++);
}

int main(int argc, char* argv[])
{
    static short u;
    static int v = 3;
    static long w = 0;

    for (int i=0; i<3; i++)
    {
        func();
    }

    long lmn = l+m+n;
    printf("lmn = %ld\n", lmn);

    long uvw = u+v+w;
    printf("uvw = %ld\n", uvw);

    printf("strlen(%s) = %zu; strlen(%s) = %zu\n", str1, strlen(str1), str2, strlen(str2));

    // Writing to read-only memory(.rodata) will raise segmentation fault(SIGSEGV) exception.
    // char *ptr = str1;
    // char *ptr = str2;
    // *ptr = 'T';
    // printf("ptr = %s\n", ptr);

    return 0;
}
```

On Raspiberry PI 3 Model B/aarch64/ubuntu, compile with `gcc`, add `-g` option to produce debugging information:

```bash
$ gcc vars-section.c -o vars-section
# gcc vars-section.c -o vars-section -g
```

## program headers

Because the object file is the intermediate result of the translation unit, it doesn't contain any program headers.

`readelf -l`(--program-headers | --segments): Display the program headers

- `objdump -x`(--all-headers): Display the contents of all headers, including Program Header.

As `readelf -lW vars-section`, both segment *LOAD0* and *LOAD1* should be aligned at 0x10000(64K).

```bash
$ readelf -lW vars-section

Elf file type is DYN (Position-Independent Executable file)
Entry point 0x7c0
There are 9 program headers, starting at offset 64

Program Headers:
  Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align
  PHDR           0x000040 0x0000000000000040 0x0000000000000040 0x0001f8 0x0001f8 R   0x8
  INTERP         0x000238 0x0000000000000238 0x0000000000000238 0x00001b 0x00001b R   0x1
      [Requesting program interpreter: /lib/ld-linux-aarch64.so.1]
  LOAD           0x000000 0x0000000000000000 0x0000000000000000 0x000d94 0x000d94 R E 0x10000
  LOAD           0x001d68 0x0000000000011d68 0x0000000000011d68 0x0002c8 0x000308 RW  0x10000
  DYNAMIC        0x001d78 0x0000000000011d78 0x0000000000011d78 0x000200 0x000200 RW  0x8
  NOTE           0x000254 0x0000000000000254 0x0000000000000254 0x000044 0x000044 R   0x4
  GNU_EH_FRAME   0x000c7c 0x0000000000000c7c 0x0000000000000c7c 0x000044 0x000044 R   0x4
  GNU_STACK      0x000000 0x0000000000000000 0x0000000000000000 0x000000 0x000000 RW  0x10
  GNU_RELRO      0x001d68 0x0000000000011d68 0x0000000000011d68 0x000298 0x000298 R   0x1

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

At this moment, `LOAD0` starts from zero of the VM is naturally aligned with 0x10000(64K), so the Address(VMA) of the sections belonging to this segment is equal to its paddr(File Offset).

Meanwhile, for the second LOAD segment `LOAD1`, there's an increment of 0x10000 from its paddr(File Offset) to its VMA.

## section headers

At this stage, sections such as `.text`, `.rodata`, `.data`, `.bss` all has determined address(VMA).

### size

Dump section headers through `size -Ax`:

```bash
$ size -Ax vars-section
vars-section  :
section               size      addr
.interp               0x1b     0x238
.note.gnu.build-id    0x24     0x254
.note.ABI-tag         0x20     0x278
.gnu.hash             0x1c     0x298
.dynsym              0x138     0x2b8
.dynstr               0xd4     0x3f0
.gnu.version          0x1a     0x4c4
.gnu.version_r        0x50     0x4e0
.rela.dyn            0x108     0x530
.rela.plt             0xa8     0x638
.init                 0x18     0x6e0
.plt                  0x90     0x700
.text                0x3d4     0x7c0
.fini                 0x14     0xb94
.rodata               0xd4     0xba8
.eh_frame_hdr         0x44     0xc7c
.eh_frame             0xd4     0xcc0
.init_array            0x8   0x11d68
.fini_array            0x8   0x11d70
.dynamic             0x200   0x11d78
.got                  0x88   0x11f78
.data                 0x30   0x12000
.bss                  0x40   0x12030
.comment              0x2b       0x0
Total                0xe50
```

### readelf

Compared to `readelf -SW vars-section.o`, the Address(VMA) field is filled at this moment.

```bash
$ readelf -SW vars-section
There are 28 section headers, starting at offset 0x2e48:

Section Headers:
  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
  [ 1] .interp           PROGBITS        0000000000000238 000238 00001b 00   A  0   0  1
  [ 2] .note.gnu.build-id NOTE            0000000000000254 000254 000024 00   A  0   0  4
  [ 3] .note.ABI-tag     NOTE            0000000000000278 000278 000020 00   A  0   0  4
  [ 4] .gnu.hash         GNU_HASH        0000000000000298 000298 00001c 00   A  5   0  8
  [ 5] .dynsym           DYNSYM          00000000000002b8 0002b8 000138 18   A  6   3  8
  [ 6] .dynstr           STRTAB          00000000000003f0 0003f0 0000d4 00   A  0   0  1
  [ 7] .gnu.version      VERSYM          00000000000004c4 0004c4 00001a 02   A  5   0  2
  [ 8] .gnu.version_r    VERNEED         00000000000004e0 0004e0 000050 00   A  6   2  8
  [ 9] .rela.dyn         RELA            0000000000000530 000530 000108 18   A  5   0  8
  [10] .rela.plt         RELA            0000000000000638 000638 0000a8 18  AI  5  21  8
  [11] .init             PROGBITS        00000000000006e0 0006e0 000018 00  AX  0   0  4
  [12] .plt              PROGBITS        0000000000000700 000700 000090 00  AX  0   0 16
  [13] .text             PROGBITS        00000000000007c0 0007c0 0003d4 00  AX  0   0 64
  [14] .fini             PROGBITS        0000000000000b94 000b94 000014 00  AX  0   0  4
  [15] .rodata           PROGBITS        0000000000000ba8 000ba8 0000d4 00   A  0   0  8
  [16] .eh_frame_hdr     PROGBITS        0000000000000c7c 000c7c 000044 00   A  0   0  4
  [17] .eh_frame         PROGBITS        0000000000000cc0 000cc0 0000d4 00   A  0   0  8
  [18] .init_array       INIT_ARRAY      0000000000011d68 001d68 000008 08  WA  0   0  8
  [19] .fini_array       FINI_ARRAY      0000000000011d70 001d70 000008 08  WA  0   0  8
  [20] .dynamic          DYNAMIC         0000000000011d78 001d78 000200 10  WA  6   0  8
  [21] .got              PROGBITS        0000000000011f78 001f78 000088 08  WA  0   0  8
  [22] .data             PROGBITS        0000000000012000 002000 000030 00  WA  0   0  8
  [23] .bss              NOBITS          0000000000012030 002030 000040 00  WA  0   0  8
  [24] .comment          PROGBITS        0000000000000000 002030 00002b 01  MS  0   0  1
  [25] .symtab           SYMTAB          0000000000000000 002060 000a38 18     26  78  8
  [26] .strtab           STRTAB          0000000000000000 002a98 0002b0 00      0   0  1
  [27] .shstrtab         STRTAB          0000000000000000 002d48 0000fa 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), p (processor specific)
```

### objdump

For all sections, VMA is equal to LMA. For sections within the second LOAD segment `LOAD1` there is a difference of 0x10000(64K) between VMA/LMA and File offset to meet alignment requirements.

The `.text` section's Flags field no longer contains the `RELOC` flag, because it's already been relocated.

```bash
$ objdump -hw vars-section

vars-section:     file format elf64-littleaarch64

Sections:
Idx Name               Size      VMA               LMA               File off  Algn  Flags
  0 .interp            0000001b  0000000000000238  0000000000000238  00000238  2**0  CONTENTS, ALLOC, LOAD, READONLY, DATA
  1 .note.gnu.build-id 00000024  0000000000000254  0000000000000254  00000254  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .note.ABI-tag      00000020  0000000000000278  0000000000000278  00000278  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .gnu.hash          0000001c  0000000000000298  0000000000000298  00000298  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .dynsym            00000138  00000000000002b8  00000000000002b8  000002b8  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  5 .dynstr            000000d4  00000000000003f0  00000000000003f0  000003f0  2**0  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .gnu.version       0000001a  00000000000004c4  00000000000004c4  000004c4  2**1  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .gnu.version_r     00000050  00000000000004e0  00000000000004e0  000004e0  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  8 .rela.dyn          00000108  0000000000000530  0000000000000530  00000530  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  9 .rela.plt          000000a8  0000000000000638  0000000000000638  00000638  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
 10 .init              00000018  00000000000006e0  00000000000006e0  000006e0  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
 11 .plt               00000090  0000000000000700  0000000000000700  00000700  2**4  CONTENTS, ALLOC, LOAD, READONLY, CODE
 12 .text              000003d4  00000000000007c0  00000000000007c0  000007c0  2**6  CONTENTS, ALLOC, LOAD, READONLY, CODE
 13 .fini              00000014  0000000000000b94  0000000000000b94  00000b94  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
 14 .rodata            000000d4  0000000000000ba8  0000000000000ba8  00000ba8  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
 15 .eh_frame_hdr      00000044  0000000000000c7c  0000000000000c7c  00000c7c  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
 16 .eh_frame          000000d4  0000000000000cc0  0000000000000cc0  00000cc0  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
 17 .init_array        00000008  0000000000011d68  0000000000011d68  00001d68  2**3  CONTENTS, ALLOC, LOAD, DATA
 18 .fini_array        00000008  0000000000011d70  0000000000011d70  00001d70  2**3  CONTENTS, ALLOC, LOAD, DATA
 19 .dynamic           00000200  0000000000011d78  0000000000011d78  00001d78  2**3  CONTENTS, ALLOC, LOAD, DATA
 20 .got               00000088  0000000000011f78  0000000000011f78  00001f78  2**3  CONTENTS, ALLOC, LOAD, DATA
 21 .data              00000030  0000000000012000  0000000000012000  00002000  2**3  CONTENTS, ALLOC, LOAD, DATA
 22 .bss               00000040  0000000000012030  0000000000012030  00002030  2**3  ALLOC
 23 .comment           0000002b  0000000000000000  0000000000000000  00002030  2**0  CONTENTS, READONLY
```

### rabin2

The vaddr(VMA) of the sections within segment `LOAD0` is equal to its paddr(File Offset).

For the second LOAD segment `LOAD1`, there's an increment of 0x10000 from its paddr(File Offset) to its vaddr(VMA) to meet alignment requirements.

```bash
$ rabin2 -S vars-section
[Sections]

nth paddr        size vaddr       vsize perm type        name
―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x00000000    0x0 0x00000000    0x0 ---- NULL
1   0x00000238   0x1b 0x00000238   0x1b -r-- PROGBITS    .interp
2   0x00000254   0x24 0x00000254   0x24 -r-- NOTE        .note.gnu.build-id
3   0x00000278   0x20 0x00000278   0x20 -r-- NOTE        .note.ABI-tag
4   0x00000298   0x1c 0x00000298   0x1c -r-- GNU_HASH    .gnu.hash
5   0x000002b8  0x138 0x000002b8  0x138 -r-- DYNSYM      .dynsym
6   0x000003f0   0xd4 0x000003f0   0xd4 -r-- STRTAB      .dynstr
7   0x000004c4   0x1a 0x000004c4   0x1a -r-- GNU_VERSYM  .gnu.version
8   0x000004e0   0x50 0x000004e0   0x50 -r-- GNU_VERNEED .gnu.version_r
9   0x00000530  0x108 0x00000530  0x108 -r-- RELA        .rela.dyn
10  0x00000638   0xa8 0x00000638   0xa8 -r-- RELA        .rela.plt
11  0x000006e0   0x18 0x000006e0   0x18 -r-x PROGBITS    .init
12  0x00000700   0x90 0x00000700   0x90 -r-x PROGBITS    .plt
13  0x000007c0  0x3d4 0x000007c0  0x3d4 -r-x PROGBITS    .text
14  0x00000b94   0x14 0x00000b94   0x14 -r-x PROGBITS    .fini
15  0x00000ba8   0xd4 0x00000ba8   0xd4 -r-- PROGBITS    .rodata
16  0x00000c7c   0x44 0x00000c7c   0x44 -r-- PROGBITS    .eh_frame_hdr
17  0x00000cc0   0xd4 0x00000cc0   0xd4 -r-- PROGBITS    .eh_frame
18  0x00001d68    0x8 0x00011d68    0x8 -rw- INIT_ARRAY  .init_array
19  0x00001d70    0x8 0x00011d70    0x8 -rw- FINI_ARRAY  .fini_array
20  0x00001d78  0x200 0x00011d78  0x200 -rw- DYNAMIC     .dynamic
21  0x00001f78   0x88 0x00011f78   0x88 -rw- PROGBITS    .got
22  0x00002000   0x30 0x00012000   0x30 -rw- PROGBITS    .data
23  0x00002030    0x0 0x00012030   0x40 -rw- NOBITS      .bss
24  0x00002030   0x2b 0x00000000   0x2b ---- PROGBITS    .comment
25  0x00002060  0xa38 0x00000000  0xa38 ---- SYMTAB      .symtab
26  0x00002a98  0x2b0 0x00000000  0x2b0 ---- STRTAB      .strtab
27  0x00002d48   0xfa 0x00000000   0xfa ---- STRTAB      .shstrtab
```

## typical sections

=== "readelf -S"

    ```bash
    $ readelf -SW vars-section
    There are 28 section headers, starting at offset 0x2e48:

    Section Headers:
      [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al

      [15] .rodata           PROGBITS        0000000000000ba8 000ba8 0000d4 00   A  0   0  8

      [22] .data             PROGBITS        0000000000012000 002000 000030 00  WA  0   0  8
      [23] .bss              NOBITS          0000000000012030 002030 000040 00  WA  0   0  8

    ```

=== "objdump -h"

    ```bash
    $ objdump -hw vars-section

    vars-section:     file format elf64-littleaarch64

    Sections:
    Idx Name               Size      VMA               LMA               File off  Algn  Flags

    14 .rodata            000000d4  0000000000000ba8  0000000000000ba8  00000ba8  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA

    21 .data              00000030  0000000000012000  0000000000012000  00002000  2**3  CONTENTS, ALLOC, LOAD, DATA
    22 .bss               00000040  0000000000012030  0000000000012030  00002030  2**3  ALLOC

    ```

=== "rabin2 -S"

    ```bash
    $ rabin2 -S vars-section
    [Sections]

    nth paddr        size vaddr       vsize perm type        name
    ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

    15  0x00000ba8   0xd4 0x00000ba8   0xd4 -r-- PROGBITS    .rodata

    22  0x00002000   0x30 0x00012000   0x30 -rw- PROGBITS    .data
    23  0x00002030    0x0 0x00012030   0x40 -rw- NOBITS      .bss

    ```

### .rodata

The following is the `.rodata` section taken from the `SYMBOL TABLE`(`objdump -x` or `objdump -t`).

```bash
0000000000000ba8 l    d  .rodata	0000000000000000              .rodata
```

> From the section headers, we can see the size of the `.rodata` section is 0xd4.

`readelf [-p|--string-dump] .rodata vars-section`: Dump the contents of section `.rodata` as strings.

```bash
$ readelf -p .rodata vars-section

String dump of section '.rodata':
  [     8]  hello
  [    10]  world
  [    18]  func global static: ijk = %ld\n
  [    38]  func locals: r+s=%d, ia[3]=%d, ca=%s\n
  [    60]  func local static: o++=%ld, ++p=%hd, q++=%d\n
  [    90]  lmn = %ld\n
  [    a0]  uvw = %ld\n
  [    b0]  strlen(%s) = %zu; strlen(%s) = %zu\n

```

The `-z` option of [rabin2](../toolchain/radare2-basics.md) is used to list readable strings found in the `.rodata` section of ELF binaries, or the `.text` section of PE files.

```bash
$ rabin2 -z vars-section
[Strings]
nth paddr      vaddr      len size section type  string
―――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x00000bb0 0x00000bb0 5   6    .rodata ascii hello
1   0x00000bb8 0x00000bb8 5   6    .rodata ascii world
2   0x00000bc0 0x00000bc0 30  31   .rodata ascii func global static: ijk = %ld\n
3   0x00000be0 0x00000be0 37  38   .rodata ascii func locals: r+s=%d, ia[3]=%d, ca=%s\n
4   0x00000c08 0x00000c08 44  45   .rodata ascii func local static: o++=%ld, ++p=%hd, q++=%d\n
5   0x00000c38 0x00000c38 10  11   .rodata ascii lmn = %ld\n
6   0x00000c48 0x00000c48 10  11   .rodata ascii uvw = %ld\n
7   0x00000c58 0x00000c58 35  36   .rodata ascii strlen(%s) = %zu; strlen(%s) = %zu\n
```

As is shown, the global `char *str1`, `static char *str2` and local `char ca[]` string literal are stored in the `.rodata` section. In addition, the *format_string* placeholders of ***std::printf*** are also in the `.rodata` section.

### .data

The following are the symbols within the `.data` section taken from the `SYMBOL TABLE`.

Pay attention to char* pointer `str1` and `str2`, they points to 0x00000bb0 and 0x00000bb8 in `.rodata`.

```bash
0000000000012000 l    d  .data	0000000000000000              .data
0000000000012000 g       .data	0000000000000000              __data_start
0000000000012000  w      .data	0000000000000000              data_start

0000000000012010 g     O .data	0000000000000002              j
0000000000012012 l     O .data	0000000000000002              m
0000000000012014 l     O .data	0000000000000002              p.4
0000000000012018 l     O .data	0000000000000004              v.1
0000000000012020 g     O .data	0000000000000008              str1
0000000000012028 l     O .data	0000000000000008              str2

0000000000012030 g       .data	0000000000000000              _edata
```

Use `readelf -x` or `objdump -j` to dump the `.data` section:

```bash
$ readelf -x .data vars-section

Hex dump of section '.data':
  0x00012000 00000000 00000000 08200100 00000000 ......... ......
  0x00012010 02000500 03000000 03000000 00000000 ................
  0x00012020 b00b0000 00000000 b80b0000 00000000 ................

$ objdump -j .data -s vars-section

vars-section:     file format elf64-littleaarch64

Contents of section .data:
 12000 00000000 00000000 08200100 00000000  ......... ......
 12010 02000500 03000000 03000000 00000000  ................
 12020 b00b0000 00000000 b80b0000 00000000  ................
```

Under Aarch64(64-bit OS), the pointer width is 8 bytes, let's check what `str1` and `str2` point to.

```bash
# 0x0000000000012020(str1)
$ rax2 -ke 0xb00b000000000000
0xbb0

# 0x0000000000012028(str2)
$ rax2 -ke 0xb80b000000000000
0xbb8
```

### .bss

!!! note "Aside: Why is uninitialized data called .bss?"

    Refer to [Computer Systems - A Programmer's Perspective](https://www.amazon.com/Computer-Systems-OHallaron-Randal-Bryant/dp/1292101768/) | Chapter 7: Linking - 7.5: Symbols and Symbol Tables:

    The use of the term `.bss` to denote uninitialized data is universal. It was originally an acronym for the “`block started by symbol`” directive from the IBM 704 assembly language (circa 1957) and the acronym has stuck. A simple way to remember the difference between the `.data` and `.bss` sections is to think of “`bss`” as an abbreviation for “*`Better Save Space!`*”

- [Linux Foundation Referenced Specifications](https://refspecs.linuxfoundation.org/) - TIS - ELF: [v1.2](https://refspecs.linuxfoundation.org/elf/elf.pdf)

Book I: Executable and Linking Format (ELF) - 1. Object Files - Sections - Special Sections

> This section holds *uninitialized* data that contribute to the program's memory image. By definition, the system **initializes** the data with *zeros* when the program begins to run. The section occupies *no* file space, as indicated by the section type, `SHT_NOBITS`(with attributes `SHF_ALLOC`+`SHF_WRITE`).

Book III: Operating System Specific (UNIX System V Release 4) - 2. Program Loading and Dynamic Linking - Program Header - Segment Contents:

> As "Sections" describes, the `.bss` section has the type `SHT_NOBITS`. Although it occupies no space in the file, it contributes to the segment's memory image. Normally, these uninitialized data reside at the end of the (Data) segment(LOAD1), thereby making `p_memsz` larger than `p_filesz`.

1. Look at the output of `readelf -l`:

    - According to the mapping, both the `.data` and `.bss` sections are placed in the second LOAD(LOAD1) data segment, `.bss` follows `.data`.
    - The Program Headers show that LOAD1's MemSiz=0x000308, FileSiz=0x0002c8, a bias of *0x40* is just the size of the `.bss` section.

2. Look at the output of `readelf -S`: Type=`NOBITS`; Flg=`WA`: W (write), A (alloc).

    > The section with type `SHT_NOBITS` occupies no file space.

3. Look at the output of `objdump -h`: Flags=`ALLOC`.

4. Look at the output of `rabin2 -S`, pay attention to the size and vsize fields of `.bss`: size=0x0, vsize=0x40.

The following are the symbols within the `.bss` section taken from the `SYMBOL TABLE`.

```bash
0000000000012030 l    d  .bss	0000000000000000              .bss
0000000000012030 g       .bss	0000000000000000              __bss_start
0000000000012030 g       .bss	0000000000000000              __bss_start__

0000000000012038 g     O .bss	0000000000000004              i
0000000000012040 g     O .bss	0000000000000008              k
0000000000012048 l     O .bss	0000000000000004              l
0000000000012050 l     O .bss	0000000000000008              n
0000000000012058 l     O .bss	0000000000000008              o.5
0000000000012060 l     O .bss	0000000000000004              q.3
0000000000012064 l     O .bss	0000000000000002              u.2
0000000000012068 l     O .bss	0000000000000008              w.0

0000000000012070 g       .bss	0000000000000000              _bss_end__
0000000000012070 g       .bss	0000000000000000              __bss_end__
0000000000012070 g       .bss	0000000000000000              _end
0000000000012070 g       .bss	0000000000000000              __end__
```

As they are not initialized, we don't need to waste file space storing them. When the system loads the program, it *allocates* pages to the `.bss` section of the process based on relevant information.

On many platforms (including Linux), the system will "*write zeros*" to these pages immediately after allocating memory pages to the `.bss` section. In fact, all the data in the `.bss` section is initialized to *`0`*.

The data that should have been stored in the `.data` section (e.g. *k*, *n*, *q*, *w*), because their initial values ​​are also 0, so gcc takes a "workaround" approach and transfers the data to the `.bss` section. This has no negative effect on the process, anyway, the system will make sure that the `.bss` section is zeroed out after loading and that their initial values ​​are all 0 before execution!

This transferation trick can help you save some disk space. If the program has a large number of external variables with initial values of zero (e.g. a large array), then this strategy can indeed result in quite significant savings.

### call

The following are the `F`(Function) symbols taken from the `SYMBOL TABLE`(`objdump -x` or `objdump -t`).

```bash
00000000000007c0 l    d  .text	0000000000000000              .text
00000000000007c0 g     F .text	0000000000000034              _start
00000000000008d4 g     F .text	0000000000000188              func
0000000000000a5c g     F .text	0000000000000138              main

0000000000000000       F *UND*	0000000000000000              printf@GLIBC_2.17
0000000000000000       F *UND*	0000000000000000              strlen@GLIBC_2.17
```
