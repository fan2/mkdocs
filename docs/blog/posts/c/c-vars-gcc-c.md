---
title: C variables representation in object(gcc -c)
authors:
    - xman
date:
    created: 2023-10-17T10:00:00
categories:
    - c
    - elf
comments: true
---

Compared to [gcc -S](./c-vars-gcc-S.md), `gcc -c` will assemble and stop linking, and generate intermediate object file, see [REL ELF Walkthrough](../elf/elf-obj-tour.md).

Object files (usually ended with `.o`) contain machine instructions that are in principle executable by the processor.

Then we can use `objdump` to display information from object files and explore what's in them.

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

On Raspiberry PI 3 Model B/aarch64/ubuntu, compile with `gcc` to produce intermediate object file:

> Compile or assemble the source files, but *do not link*. The linking stage simply is not done.
> The ultimate output is in the form of an ***object file*** for each source file.
> By default, the object file name for a source file is made by replacing the suffix ‘.c’, ‘.i’, ‘.s’, etc., with ‘`.o`’.

```bash
# output -o vars-section.o
$ gcc vars-section.c -c
```

## nm

`nm`: List symbols in file(s).

- `readelf -s --syms`: Display the symbol table
- `objdump -t, --syms`: Display the contents of the symbol table(s)

```bash
# nm vars-section.o
# -S, --print-size
$ nm -S vars-section.o
0000000000000000 0000000000000188 T func
0000000000000000 0000000000000004 B i
0000000000000000 0000000000000002 D j
0000000000000008 0000000000000008 B k
0000000000000010 0000000000000004 b l
0000000000000002 0000000000000002 d m
0000000000000188 0000000000000130 T main
0000000000000018 0000000000000008 b n
0000000000000020 0000000000000008 b o.5
0000000000000004 0000000000000002 d p.4
                 U printf
0000000000000028 0000000000000004 b q.3
                 U __stack_chk_fail
                 U __stack_chk_guard
0000000000000000 0000000000000008 D str1
0000000000000008 0000000000000008 d str2
                 U strlen
000000000000002c 0000000000000002 b u.2
0000000000000008 0000000000000004 d v.1
0000000000000030 0000000000000008 b w.0
```

!!! note "nm symbol type"

    Refer to [nm](https://man7.org/linux/man-pages/man1/nm.1.html) for a knowledge of the symbol type, such as `T`/`t`,`D`/`d`,`B`/`b`,`U`, etc.

> If lowercase, the symbol is usually ***local***; if uppercase, the symbol is ***global*** (external).
> There are however a few lowercase symbols that are shown for special global symbols ("u", "v" and "w").

extern functions defined in the object(translation unit):

symbol                 | meaning
-----------------------|----------------------------------
`T main`, `T func`     | in the `text` (code) section

extern std functions referenced by *`main()`* and *`func()`*:

symbol                 | meaning
-----------------------|----------------------------------
`U strlen`, `U printf` | undefined(defined externally)

global/extern `i`, `j`, `k`, declared/defined outside *`main()`*:

symbol                 | meaning
-----------------------|----------------------------------
`B i`, `B k`           | in the `BSS` data section
`D j`                  | in the initialized `data` section

local/static `l`, `m`, `n`, declared/defined outside *`main()`*:

symbol                 | meaning
-----------------------|----------------------------------
`b l`, `b n`           | in the `BSS` data section
`d m`                  | in the initialized `data` section

global/extern `char *str1`, local `static char *str2` defined outside *`main()`*:

symbol                 | meaning
-----------------------|----------------------------------
`D str1`               | in the initialized `data` section
`d str2`               | in the initialized `data` section

local static integers defined inside in *`func()`*:

symbol                 | meaning
-----------------------|----------------------------------
`b o.5`, `b q.3`       | in the `BSS` data section
`d p.4`                | in the initialized `data` section

local static integers defined inside in *`main()`*:

symbol                 | meaning
-----------------------|----------------------------------
`b u.2`, `b w.0`       | in the `BSS` data section
`d v.1`                | in the initialized `data` section

### nm -g

`nm -g`(--extern-only): Display only external symbols.

External symbols are all capital letters accessible across files.

1. `T`(text): global function symbol
3. `D`(data): global initialized variables
2. `B`(BSS): global uninitialized variables, automatically initialized with 0 by the loader
4. `U`(undefined): a promise to the compiler that there would be a definition of a global variable some place else

```bash
$ nm -g vars-section.o
0000000000000000 T func
0000000000000000 B i
0000000000000000 D j
0000000000000008 B k
0000000000000188 T main
                 U printf
                 U __stack_chk_fail
                 U __stack_chk_guard
0000000000000000 D str1
                 U strlen
```

## objdump

`-x, --all-headers`: Display the contents of all headers
`-w, --wide`: Format output for more than 80 columns

- `-h, --[section-]headers`: Display the contents of the section headers

    - `readelf -S --section-headers`: Display the sections' header

- `-t, --syms`: Display the contents of the symbol table(s)

    - `readelf -s --syms`: Display the symbol table

### all-headers

The output of `objdump -x` mainly consists of three parts:

1. general information of the object
2. Sections
3. SYMBOL TABLE
4. RELOCATION RECORDS

For the output, the most critical is the `HAS_RELOC` flag.
The offset of the *start address* relative to the start address of the ".text" section is `0x0000000000000000`.
The start address of each section (LMA and VMA) is `0x0000000000000000`, because all addresses are not yet determined.
Therefore, symbols within the sections are filled with relative address(offset to the start of its section) at this stage.

```bash
$ objdump -xw vars-section.o

vars-section.o:     file format elf64-littleaarch64
vars-section.o
architecture: aarch64, flags 0x00000011:
HAS_RELOC, HAS_SYMS
start address 0x0000000000000000
private flags = 0x0:

Sections:
Idx Name            Size      VMA               LMA               File off  Algn  Flags
  0 .text           000002c0  0000000000000000  0000000000000000  00000040  2**2  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data           0000000c  0000000000000000  0000000000000000  00000300  2**2  CONTENTS, ALLOC, LOAD, DATA
  2 .bss            00000038  0000000000000000  0000000000000000  00000310  2**3  ALLOC
  3 .rodata         000000cc  0000000000000000  0000000000000000  00000310  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .data.rel.local 00000010  0000000000000000  0000000000000000  000003e0  2**3  CONTENTS, ALLOC, LOAD, RELOC, DATA
  5 .comment        0000002c  0000000000000000  0000000000000000  000003f0  2**0  CONTENTS, READONLY
  6 .note.GNU-stack 00000000  0000000000000000  0000000000000000  0000041c  2**0  CONTENTS, READONLY
  7 .eh_frame       00000060  0000000000000000  0000000000000000  00000420  2**3  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA
SYMBOL TABLE:
0000000000000000 l    df *ABS*	0000000000000000 vars-section.c
0000000000000000 l    d  .text	0000000000000000 .text
0000000000000000 l    d  .data	0000000000000000 .data
0000000000000000 l    d  .bss	0000000000000000 .bss
0000000000000010 l     O .bss	0000000000000004 l
0000000000000002 l     O .data	0000000000000002 m
0000000000000018 l     O .bss	0000000000000008 n
0000000000000000 l    d  .rodata	0000000000000000 .rodata
0000000000000000 l    d  .data.rel.local	0000000000000000 .data.rel.local
0000000000000008 l     O .data.rel.local	0000000000000008 str2
0000000000000020 l     O .bss	0000000000000008 o.5
0000000000000004 l     O .data	0000000000000002 p.4
0000000000000028 l     O .bss	0000000000000004 q.3
000000000000002c l     O .bss	0000000000000002 u.2
0000000000000008 l     O .data	0000000000000004 v.1
0000000000000030 l     O .bss	0000000000000008 w.0
0000000000000000 l    d  .note.GNU-stack	0000000000000000 .note.GNU-stack
0000000000000000 l    d  .eh_frame	0000000000000000 .eh_frame
0000000000000000 l    d  .comment	0000000000000000 .comment
0000000000000000 g     O .bss	0000000000000004 i
0000000000000000 g     O .data	0000000000000002 j
0000000000000008 g     O .bss	0000000000000008 k
0000000000000000 g     O .data.rel.local	0000000000000008 str1
0000000000000000 g     F .text	0000000000000188 func
0000000000000000         *UND*	0000000000000000 __stack_chk_guard
0000000000000000         *UND*	0000000000000000 printf
0000000000000000         *UND*	0000000000000000 __stack_chk_fail
0000000000000188 g     F .text	0000000000000138 main
0000000000000000         *UND*	0000000000000000 strlen


RELOCATION RECORDS FOR [.text]:
OFFSET           TYPE              VALUE
0000000000000008 R_AARCH64_ADR_GOT_PAGE  __stack_chk_guard
000000000000000c R_AARCH64_LD64_GOT_LO12_NC  __stack_chk_guard
0000000000000048 R_AARCH64_ADR_PREL_PG_HI21  .rodata
000000000000004c R_AARCH64_ADD_ABS_LO12_NC  .rodata
0000000000000064 R_AARCH64_ADR_PREL_PG_HI21  j
0000000000000068 R_AARCH64_ADD_ABS_LO12_NC  j
0000000000000074 R_AARCH64_ADR_PREL_PG_HI21  i
0000000000000078 R_AARCH64_ADD_ABS_LO12_NC  i
0000000000000088 R_AARCH64_ADR_PREL_PG_HI21  k
000000000000008c R_AARCH64_ADD_ABS_LO12_NC  k
000000000000009c R_AARCH64_ADR_PREL_PG_HI21  .rodata+0x0000000000000010
00000000000000a0 R_AARCH64_ADD_ABS_LO12_NC  .rodata+0x0000000000000010
00000000000000a4 R_AARCH64_CALL26  printf
00000000000000c8 R_AARCH64_ADR_PREL_PG_HI21  .rodata+0x0000000000000030
00000000000000cc R_AARCH64_ADD_ABS_LO12_NC  .rodata+0x0000000000000030
00000000000000d0 R_AARCH64_CALL26  printf
00000000000000d4 R_AARCH64_ADR_PREL_PG_HI21  .bss+0x0000000000000020
00000000000000d8 R_AARCH64_ADD_ABS_LO12_NC  .bss+0x0000000000000020
00000000000000e4 R_AARCH64_ADR_PREL_PG_HI21  .bss+0x0000000000000020
00000000000000e8 R_AARCH64_ADD_ABS_LO12_NC  .bss+0x0000000000000020
00000000000000f0 R_AARCH64_ADR_PREL_PG_HI21  .data+0x0000000000000004
00000000000000f4 R_AARCH64_ADD_ABS_LO12_NC  .data+0x0000000000000004
000000000000010c R_AARCH64_ADR_PREL_PG_HI21  .data+0x0000000000000004
0000000000000110 R_AARCH64_ADD_ABS_LO12_NC  .data+0x0000000000000004
0000000000000118 R_AARCH64_ADR_PREL_PG_HI21  .data+0x0000000000000004
000000000000011c R_AARCH64_ADD_ABS_LO12_NC  .data+0x0000000000000004
0000000000000128 R_AARCH64_ADR_PREL_PG_HI21  .bss+0x0000000000000028
000000000000012c R_AARCH64_ADD_ABS_LO12_NC  .bss+0x0000000000000028
0000000000000138 R_AARCH64_ADR_PREL_PG_HI21  .bss+0x0000000000000028
000000000000013c R_AARCH64_ADD_ABS_LO12_NC  .bss+0x0000000000000028
0000000000000150 R_AARCH64_ADR_PREL_PG_HI21  .rodata+0x0000000000000058
0000000000000154 R_AARCH64_ADD_ABS_LO12_NC  .rodata+0x0000000000000058
0000000000000158 R_AARCH64_CALL26  printf
0000000000000160 R_AARCH64_ADR_GOT_PAGE  __stack_chk_guard
0000000000000164 R_AARCH64_LD64_GOT_LO12_NC  __stack_chk_guard
000000000000017c R_AARCH64_CALL26  __stack_chk_fail
00000000000001a8 R_AARCH64_CALL26  func
00000000000001c4 R_AARCH64_ADR_PREL_PG_HI21  .data+0x0000000000000002
00000000000001c8 R_AARCH64_ADD_ABS_LO12_NC  .data+0x0000000000000002
00000000000001d4 R_AARCH64_ADR_PREL_PG_HI21  .bss+0x0000000000000010
00000000000001d8 R_AARCH64_ADD_ABS_LO12_NC  .bss+0x0000000000000010
00000000000001e8 R_AARCH64_ADR_PREL_PG_HI21  .bss+0x0000000000000018
00000000000001ec R_AARCH64_ADD_ABS_LO12_NC  .bss+0x0000000000000018
0000000000000200 R_AARCH64_ADR_PREL_PG_HI21  .rodata+0x0000000000000088
0000000000000204 R_AARCH64_ADD_ABS_LO12_NC  .rodata+0x0000000000000088
0000000000000208 R_AARCH64_CALL26  printf
000000000000020c R_AARCH64_ADR_PREL_PG_HI21  .bss+0x000000000000002c
0000000000000210 R_AARCH64_ADD_ABS_LO12_NC  .bss+0x000000000000002c
000000000000021c R_AARCH64_ADR_PREL_PG_HI21  .data+0x0000000000000008
0000000000000220 R_AARCH64_ADD_ABS_LO12_NC  .data+0x0000000000000008
0000000000000230 R_AARCH64_ADR_PREL_PG_HI21  .bss+0x0000000000000030
0000000000000234 R_AARCH64_ADD_ABS_LO12_NC  .bss+0x0000000000000030
0000000000000248 R_AARCH64_ADR_PREL_PG_HI21  .rodata+0x0000000000000098
000000000000024c R_AARCH64_ADD_ABS_LO12_NC  .rodata+0x0000000000000098
0000000000000250 R_AARCH64_CALL26  printf
0000000000000254 R_AARCH64_ADR_PREL_PG_HI21  str1
0000000000000258 R_AARCH64_ADD_ABS_LO12_NC  str1
0000000000000260 R_AARCH64_ADR_PREL_PG_HI21  str1
0000000000000264 R_AARCH64_ADD_ABS_LO12_NC  str1
000000000000026c R_AARCH64_CALL26  strlen
0000000000000274 R_AARCH64_ADR_PREL_PG_HI21  .data.rel.local+0x0000000000000008
0000000000000278 R_AARCH64_ADD_ABS_LO12_NC  .data.rel.local+0x0000000000000008
0000000000000280 R_AARCH64_ADR_PREL_PG_HI21  .data.rel.local+0x0000000000000008
0000000000000284 R_AARCH64_ADD_ABS_LO12_NC  .data.rel.local+0x0000000000000008
000000000000028c R_AARCH64_CALL26  strlen
00000000000002a0 R_AARCH64_ADR_PREL_PG_HI21  .rodata+0x00000000000000a8
00000000000002a4 R_AARCH64_ADD_ABS_LO12_NC  .rodata+0x00000000000000a8
00000000000002a8 R_AARCH64_CALL26  printf


RELOCATION RECORDS FOR [.data.rel.local]:
OFFSET           TYPE              VALUE
0000000000000000 R_AARCH64_ABS64   .rodata
0000000000000008 R_AARCH64_ABS64   .rodata+0x0000000000000008


RELOCATION RECORDS FOR [.eh_frame]:
OFFSET           TYPE              VALUE
000000000000001c R_AARCH64_PREL32  .text
000000000000003c R_AARCH64_PREL32  .text+0x0000000000000188


```

### disassemble

`-d, --disassemble`: Display assembler contents of executable sections.

Compared to `objdump -x`, the disassembly part of `objdump -xd` already contains RELOCATION RECORDS.

1. general information of the object
2. Sections
3. SYMBOL TABLE
4. Disassembly(implies RELOCATION RECORDS)

The disassembly clearly indicates where ***relocations*** must be made by the linker.

```bash
$ objdump -xdw vars-section.o

vars-section.o:     file format elf64-littleaarch64
vars-section.o
architecture: aarch64, flags 0x00000011:
HAS_RELOC, HAS_SYMS
start address 0x0000000000000000
private flags = 0x0:

Sections:

[...snip...]

SYMBOL TABLE:

[...snip...]

Disassembly of section .text:

0000000000000000 <func>:
   0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   4:	910003fd 	mov	x29, sp
   8:	90000000 	adrp	x0, 0 <__stack_chk_guard>	8: R_AARCH64_ADR_GOT_PAGE	__stack_chk_guard
   c:	f9400000 	ldr	x0, [x0]	c: R_AARCH64_LD64_GOT_LO12_NC	__stack_chk_guard
  10:	f9400001 	ldr	x1, [x0]
  14:	f9001fe1 	str	x1, [sp, #56]
  18:	d2800001 	mov	x1, #0x0                   	// #0
  1c:	52800080 	mov	w0, #0x4                   	// #4
  20:	b9001be0 	str	w0, [sp, #24]
  24:	52800040 	mov	w0, #0x2                   	// #2
  28:	b90023e0 	str	w0, [sp, #32]
  2c:	b90027ff 	str	wzr, [sp, #36]
  30:	52800080 	mov	w0, #0x4                   	// #4
  34:	b9002be0 	str	w0, [sp, #40]
  38:	52800100 	mov	w0, #0x8                   	// #8
  3c:	b9002fe0 	str	w0, [sp, #44]
  40:	528000a0 	mov	w0, #0x5                   	// #5
  44:	b9001fe0 	str	w0, [sp, #28]
  48:	90000000 	adrp	x0, 0 <func>	48: R_AARCH64_ADR_PREL_PG_HI21	.rodata
  4c:	91000001 	add	x1, x0, #0x0	4c: R_AARCH64_ADD_ABS_LO12_NC	.rodata
  50:	9100c3e0 	add	x0, sp, #0x30
  54:	b9400022 	ldr	w2, [x1]
  58:	b9000002 	str	w2, [x0]
  5c:	79400821 	ldrh	w1, [x1, #4]
  60:	79000801 	strh	w1, [x0, #4]
  64:	90000000 	adrp	x0, 0 <func>	64: R_AARCH64_ADR_PREL_PG_HI21	j
  68:	91000000 	add	x0, x0, #0x0	68: R_AARCH64_ADD_ABS_LO12_NC	j
  6c:	79c00000 	ldrsh	w0, [x0]
  70:	2a0003e1 	mov	w1, w0
  74:	90000000 	adrp	x0, 0 <func>	74: R_AARCH64_ADR_PREL_PG_HI21	i
  78:	91000000 	add	x0, x0, #0x0	78: R_AARCH64_ADD_ABS_LO12_NC	i
  7c:	b9400000 	ldr	w0, [x0]
  80:	0b000020 	add	w0, w1, w0
  84:	93407c01 	sxtw	x1, w0
  88:	90000000 	adrp	x0, 8 <func+0x8>	88: R_AARCH64_ADR_PREL_PG_HI21	k
  8c:	91000000 	add	x0, x0, #0x0	8c: R_AARCH64_ADD_ABS_LO12_NC	k
  90:	f9400000 	ldr	x0, [x0]
  94:	8b000020 	add	x0, x1, x0
  98:	aa0003e1 	mov	x1, x0
  9c:	90000000 	adrp	x0, 0 <func>	9c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x10
  a0:	91000000 	add	x0, x0, #0x0	a0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x10
  a4:	94000000 	bl	0 <printf>	a4: R_AARCH64_CALL26	printf
  a8:	b9401be1 	ldr	w1, [sp, #24]
  ac:	b9401fe0 	ldr	w0, [sp, #28]
  b0:	0b000020 	add	w0, w1, w0
  b4:	b9402fe1 	ldr	w1, [sp, #44]
  b8:	9100c3e2 	add	x2, sp, #0x30
  bc:	aa0203e3 	mov	x3, x2
  c0:	2a0103e2 	mov	w2, w1
  c4:	2a0003e1 	mov	w1, w0
  c8:	90000000 	adrp	x0, 0 <func>	c8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x30
  cc:	91000000 	add	x0, x0, #0x0	cc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x30
  d0:	94000000 	bl	0 <printf>	d0: R_AARCH64_CALL26	printf
  d4:	90000000 	adrp	x0, 0 <func>	d4: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x20
  d8:	91000000 	add	x0, x0, #0x0	d8: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x20
  dc:	f9400000 	ldr	x0, [x0]
  e0:	91000402 	add	x2, x0, #0x1
  e4:	90000001 	adrp	x1, 0 <func>	e4: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x20
  e8:	91000021 	add	x1, x1, #0x0	e8: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x20
  ec:	f9000022 	str	x2, [x1]
  f0:	90000001 	adrp	x1, 0 <func>	f0: R_AARCH64_ADR_PREL_PG_HI21	.data+0x4
  f4:	91000021 	add	x1, x1, #0x0	f4: R_AARCH64_ADD_ABS_LO12_NC	.data+0x4
  f8:	79c00021 	ldrsh	w1, [x1]
  fc:	12003c21 	and	w1, w1, #0xffff
 100:	11000421 	add	w1, w1, #0x1
 104:	12003c21 	and	w1, w1, #0xffff
 108:	13003c22 	sxth	w2, w1
 10c:	90000001 	adrp	x1, 0 <func>	10c: R_AARCH64_ADR_PREL_PG_HI21	.data+0x4
 110:	91000021 	add	x1, x1, #0x0	110: R_AARCH64_ADD_ABS_LO12_NC	.data+0x4
 114:	79000022 	strh	w2, [x1]
 118:	90000001 	adrp	x1, 0 <func>	118: R_AARCH64_ADR_PREL_PG_HI21	.data+0x4
 11c:	91000021 	add	x1, x1, #0x0	11c: R_AARCH64_ADD_ABS_LO12_NC	.data+0x4
 120:	79c00021 	ldrsh	w1, [x1]
 124:	2a0103e4 	mov	w4, w1
 128:	90000001 	adrp	x1, 0 <func>	128: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x28
 12c:	91000021 	add	x1, x1, #0x0	12c: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x28
 130:	b9400021 	ldr	w1, [x1]
 134:	11000423 	add	w3, w1, #0x1
 138:	90000002 	adrp	x2, 0 <func>	138: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x28
 13c:	91000042 	add	x2, x2, #0x0	13c: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x28
 140:	b9000043 	str	w3, [x2]
 144:	2a0103e3 	mov	w3, w1
 148:	2a0403e2 	mov	w2, w4
 14c:	aa0003e1 	mov	x1, x0
 150:	90000000 	adrp	x0, 0 <func>	150: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x58
 154:	91000000 	add	x0, x0, #0x0	154: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x58
 158:	94000000 	bl	0 <printf>	158: R_AARCH64_CALL26	printf
 15c:	d503201f 	nop
 160:	90000000 	adrp	x0, 0 <__stack_chk_guard>	160: R_AARCH64_ADR_GOT_PAGE	__stack_chk_guard
 164:	f9400000 	ldr	x0, [x0]	164: R_AARCH64_LD64_GOT_LO12_NC	__stack_chk_guard
 168:	f9401fe2 	ldr	x2, [sp, #56]
 16c:	f9400001 	ldr	x1, [x0]
 170:	eb010042 	subs	x2, x2, x1
 174:	d2800001 	mov	x1, #0x0                   	// #0
 178:	54000040 	b.eq	180 <func+0x180>  // b.none
 17c:	94000000 	bl	0 <__stack_chk_fail>	17c: R_AARCH64_CALL26	__stack_chk_fail
 180:	a8c47bfd 	ldp	x29, x30, [sp], #64
 184:	d65f03c0 	ret

0000000000000188 <main>:
 188:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
 18c:	910003fd 	mov	x29, sp
 190:	a90153f3 	stp	x19, x20, [sp, #16]
 194:	f90013f5 	str	x21, [sp, #32]
 198:	b9003fe0 	str	w0, [sp, #60]
 19c:	f9001be1 	str	x1, [sp, #48]
 1a0:	b9004fff 	str	wzr, [sp, #76]
 1a4:	14000005 	b	1b8 <main+0x30>
 1a8:	94000000 	bl	0 <func>	1a8: R_AARCH64_CALL26	func
 1ac:	b9404fe0 	ldr	w0, [sp, #76]
 1b0:	11000400 	add	w0, w0, #0x1
 1b4:	b9004fe0 	str	w0, [sp, #76]
 1b8:	b9404fe0 	ldr	w0, [sp, #76]
 1bc:	7100081f 	cmp	w0, #0x2
 1c0:	54ffff4d 	b.le	1a8 <main+0x20>
 1c4:	90000000 	adrp	x0, 0 <func>	1c4: R_AARCH64_ADR_PREL_PG_HI21	.data+0x2
 1c8:	91000000 	add	x0, x0, #0x0	1c8: R_AARCH64_ADD_ABS_LO12_NC	.data+0x2
 1cc:	79c00000 	ldrsh	w0, [x0]
 1d0:	2a0003e1 	mov	w1, w0
 1d4:	90000000 	adrp	x0, 0 <func>	1d4: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x10
 1d8:	91000000 	add	x0, x0, #0x0	1d8: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x10
 1dc:	b9400000 	ldr	w0, [x0]
 1e0:	0b000020 	add	w0, w1, w0
 1e4:	93407c01 	sxtw	x1, w0
 1e8:	90000000 	adrp	x0, 0 <func>	1e8: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x18
 1ec:	91000000 	add	x0, x0, #0x0	1ec: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x18
 1f0:	f9400000 	ldr	x0, [x0]
 1f4:	8b000020 	add	x0, x1, x0
 1f8:	f9002be0 	str	x0, [sp, #80]
 1fc:	f9402be1 	ldr	x1, [sp, #80]
 200:	90000000 	adrp	x0, 0 <func>	200: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x88
 204:	91000000 	add	x0, x0, #0x0	204: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x88
 208:	94000000 	bl	0 <printf>	208: R_AARCH64_CALL26	printf
 20c:	90000000 	adrp	x0, 0 <func>	20c: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x2c
 210:	91000000 	add	x0, x0, #0x0	210: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x2c
 214:	79c00000 	ldrsh	w0, [x0]
 218:	2a0003e1 	mov	w1, w0
 21c:	90000000 	adrp	x0, 0 <func>	21c: R_AARCH64_ADR_PREL_PG_HI21	.data+0x8
 220:	91000000 	add	x0, x0, #0x0	220: R_AARCH64_ADD_ABS_LO12_NC	.data+0x8
 224:	b9400000 	ldr	w0, [x0]
 228:	0b000020 	add	w0, w1, w0
 22c:	93407c01 	sxtw	x1, w0
 230:	90000000 	adrp	x0, 0 <func>	230: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x30
 234:	91000000 	add	x0, x0, #0x0	234: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x30
 238:	f9400000 	ldr	x0, [x0]
 23c:	8b000020 	add	x0, x1, x0
 240:	f9002fe0 	str	x0, [sp, #88]
 244:	f9402fe1 	ldr	x1, [sp, #88]
 248:	90000000 	adrp	x0, 0 <func>	248: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x98
 24c:	91000000 	add	x0, x0, #0x0	24c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x98
 250:	94000000 	bl	0 <printf>	250: R_AARCH64_CALL26	printf
 254:	90000000 	adrp	x0, 0 <func>	254: R_AARCH64_ADR_PREL_PG_HI21	str1
 258:	91000000 	add	x0, x0, #0x0	258: R_AARCH64_ADD_ABS_LO12_NC	str1
 25c:	f9400013 	ldr	x19, [x0]
 260:	90000000 	adrp	x0, 0 <func>	260: R_AARCH64_ADR_PREL_PG_HI21	str1
 264:	91000000 	add	x0, x0, #0x0	264: R_AARCH64_ADD_ABS_LO12_NC	str1
 268:	f9400000 	ldr	x0, [x0]
 26c:	94000000 	bl	0 <strlen>	26c: R_AARCH64_CALL26	strlen
 270:	aa0003f5 	mov	x21, x0
 274:	90000000 	adrp	x0, 0 <func>	274: R_AARCH64_ADR_PREL_PG_HI21	.data.rel.local+0x8
 278:	91000000 	add	x0, x0, #0x0	278: R_AARCH64_ADD_ABS_LO12_NC	.data.rel.local+0x8
 27c:	f9400014 	ldr	x20, [x0]
 280:	90000000 	adrp	x0, 0 <func>	280: R_AARCH64_ADR_PREL_PG_HI21	.data.rel.local+0x8
 284:	91000000 	add	x0, x0, #0x0	284: R_AARCH64_ADD_ABS_LO12_NC	.data.rel.local+0x8
 288:	f9400000 	ldr	x0, [x0]
 28c:	94000000 	bl	0 <strlen>	28c: R_AARCH64_CALL26	strlen
 290:	aa0003e4 	mov	x4, x0
 294:	aa1403e3 	mov	x3, x20
 298:	aa1503e2 	mov	x2, x21
 29c:	aa1303e1 	mov	x1, x19
 2a0:	90000000 	adrp	x0, 0 <func>	2a0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xa8
 2a4:	91000000 	add	x0, x0, #0x0	2a4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xa8
 2a8:	94000000 	bl	0 <printf>	2a8: R_AARCH64_CALL26	printf
 2ac:	52800000 	mov	w0, #0x0                   	// #0
 2b0:	a94153f3 	ldp	x19, x20, [sp, #16]
 2b4:	f94013f5 	ldr	x21, [sp, #32]
 2b8:	a8c67bfd 	ldp	x29, x30, [sp], #96
 2bc:	d65f03c0 	ret
```

## RELOCATION

Pay attention to the output of `objdump -xw`, it lists out all `RELOCATION RECORDS FOR [.text]`.
Between `RELOCATION RECORDS` and `SYMBOL TABLE` there is a strict one-to-one correlation.

### .rodata

Look at disassemble snippets of func() that references `.rodata`:

```bash
  48:	90000000 	adrp	x0, 0 <func>	48: R_AARCH64_ADR_PREL_PG_HI21	.rodata
  4c:	91000001 	add	x1, x0, #0x0	4c: R_AARCH64_ADD_ABS_LO12_NC	.rodata
```

The global `char *str1` is located at the top of the `.data.rel.local`(alias of `.rodata`) section.

```bash
SYMBOL TABLE:

0000000000000000 g     O .data.rel.local	0000000000000008 str1

RELOCATION RECORDS FOR [.data.rel.local]:
OFFSET           TYPE              VALUE
0000000000000000 R_AARCH64_ABS64   .rodata
```

Check against the `.rodata` section:

```bash
# readelf -x .rodata vars-section.o
$ objdump -j .rodata -s vars-section.o

vars-section.o:     file format elf64-littleaarch64

Contents of section .rodata:
 0000 68656c6c 6f000000 776f726c 64000000  hello...world...
 0010 66756e63 20676c6f 62616c20 73746174  func global stat
 0020 69633a20 696a6b20 3d20256c 640a0000  ic: ijk = %ld...
 0030 66756e63 206c6f63 616c733a 20722b73  func locals: r+s
 0040 3d25642c 2069615b 335d3d25 642c2063  =%d, ia[3]=%d, c
 0050 613d2573 0a000000 66756e63 206c6f63  a=%s....func loc
 0060 616c2073 74617469 633a206f 2b2b3d25  al static: o++=%
 0070 6c642c20 2b2b703d 2568642c 20712b2b  ld, ++p=%hd, q++
 0080 3d25640a 00000000 6c6d6e20 3d20256c  =%d.....lmn = %l
 0090 640a0000 00000000 75767720 3d20256c  d.......uvw = %l
 00a0 640a0000 00000000 7374726c 656e2825  d.......strlen(%
 00b0 7329203d 20257a75 3b207374 726c656e  s) = %zu; strlen
 00c0 28257329 203d2025 7a750a00           (%s) = %zu..

$ rabin2 -z vars-section.o
[Strings]
nth paddr      vaddr      len size section type  string
―――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x00000310 0x08000310 5   6    .rodata ascii hello
1   0x00000318 0x08000318 5   6    .rodata ascii world
2   0x00000320 0x08000320 30  31   .rodata ascii func global static: ijk = %ld\n
3   0x00000340 0x08000340 37  38   .rodata ascii func locals: r+s=%d, ia[3]=%d, ca=%s\n
4   0x00000368 0x08000368 44  45   .rodata ascii func local static: o++=%ld, ++p=%hd, q++=%d\n
5   0x00000398 0x08000398 10  11   .rodata ascii lmn = %ld\n
6   0x000003a8 0x080003a8 10  11   .rodata ascii uvw = %ld\n
7   0x000003b8 0x080003b8 35  36   .rodata ascii strlen(%s) = %zu; strlen(%s) = %zu\n
```

`.rodata+0x10` referenced by func() stands for `func global static: ijk = %ld\n`.

```bash
# disassemble snippets

  9c:	90000000 	adrp	x0, 0 <func>	9c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x10
  a0:	91000000 	add	x0, x0, #0x0	a0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x10
  a4:	94000000 	bl	0 <printf>	a4: R_AARCH64_CALL26	printf
```

`.rodata+0xa8` referenced by main() represents `strlen(%s) = %zu; strlen(%s) = %zu\n`.

```bash
# disassemble snippets

 2a0:	90000000 	adrp	x0, 0 <func>	2a0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xa8
 2a4:	91000000 	add	x0, x0, #0x0	2a4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xa8
 2a8:	94000000 	bl	0 <printf>	2a8: R_AARCH64_CALL26	printf
```

!!! note ".rodata relocation"

    Once the linker has determined the start address of the `.rodata` section, the linker only needs to add the value of the start address of the `.rodata` section to the places(relative offset) that need to be relocated.

### .data

Look at disassemble snippets of func() that references `.data+0x4`:

```bash
 10c:	90000001 	adrp	x1, 0 <func>	10c: R_AARCH64_ADR_PREL_PG_HI21	.data+0x4
 110:	91000021 	add	x1, x1, #0x0	110: R_AARCH64_ADD_ABS_LO12_NC	.data+0x4
```

According to `SYMBOL TABLE`, `.data+0x4` represents local `p` defined in func():

```bash
SYMBOL TABLE:

0000000000000004 l     O .data	0000000000000002 p.4
```

Look at disassemble snippets of main() that references `.data+0x2`:

```bash
 1c4:	90000000 	adrp	x0, 0 <func>	1c4: R_AARCH64_ADR_PREL_PG_HI21	.data+0x2
 1c8:	91000000 	add	x0, x0, #0x0	1c8: R_AARCH64_ADD_ABS_LO12_NC	.data+0x2
```

According to `SYMBOL TABLE`, `.data+0x2` represents static `m` defined outside main():

```bash
SYMBOL TABLE:

0000000000000002 l     O .data	0000000000000002 m
```

!!! note ".data relocation"

    Once the linker has determined the start address of the `.data` section, the locations/values ​​of `m` and `p` are also determined.
    At that time, the linker only needs to add the value of the start address of the `.data` section to the places(relative offset) that need to be relocated.

### .bss

Look at disassemble snippets of func() that references `.bss+0x20`:

```bash
  d4:	90000000 	adrp	x0, 0 <func>	d4: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x20
  d8:	91000000 	add	x0, x0, #0x0	d8: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x20
```

According to `SYMBOL TABLE`, `.bss+0x20` represents static `o` defined in func():

```bash
SYMBOL TABLE:

0000000000000020 l     O .bss	0000000000000008 o.5
```

Look at disassemble snippets of main() that references `.bss+0x10`:

```bash
 1d4:	90000000 	adrp	x0, 0 <func>	1d4: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x10
 1d8:	91000000 	add	x0, x0, #0x0	1d8: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x10
```

According to `SYMBOL TABLE`, `.bss+0x10` represents static uninitialized `l` defined outside main():

```bash
SYMBOL TABLE:

0000000000000010 l     O .bss	0000000000000004 l
```

!!! note ".bss relocation"

    Once the linker has determined the start address of the `.bss` section, the locations/values ​​of `l` and `o` are also determined.
    At that time, the linker only needs to add the value of the start address of the `.bss` section to the places(relative offset) that need to be relocated.

### call

Data relocation is generally based on the base address of the section and the offset of the variable, while code relocation in the ARM system is mainly implemented based on the `B` series branch jump instructions. Refer to [ARM64 PCS - Procedure Call Standard](../arm/a64-pcs-concepts.md).

**Branch relevant instructions**:

- `B`: Branch.
- `B.cond`: Branch conditionally.
- `BC.cond`: Branch consistent conditionally.
- `BL`: Branch with link.
- `BLR`: Branch with link to register.
- `BR`: Branch to register.

**Compare and branch**:

These instructions are used to branch conditionally if a register is zero or nonzero (or if a bit is zero or nonzero):

- `cbz`: Compare and Branch if Zero,
- `cbnz`: Compare and Branch if Nonzero,
- `tbz`: Test Bit and Branch if Zero, and
- `tbnz`: Test Bit and Branch if Nonzero.

The main() routine mainly invokes three subroutines: func(), printf() and strlen().
The subroutine calls are all translated into `bl 0` in the assembler.
There is a relocation record following every bl instruction.

```bash
 1a8:   94000000    bl  0 <func>    1a8: R_AARCH64_CALL26   func

 208:   94000000    bl  0 <printf>  208: R_AARCH64_CALL26   printf

 250:   94000000    bl  0 <printf>  250: R_AARCH64_CALL26   printf

 26c:   94000000    bl  0 <strlen>  26c: R_AARCH64_CALL26   strlen

 28c:   94000000    bl  0 <strlen>  28c: R_AARCH64_CALL26   strlen
```

Refer to [puts@plt/rela/got - static analysis](../elf/plt-puts-analysis.md) to see information about `ELF64_R_TYPE`.

```c
// /usr/include/elf.h

/* ELF64_R_TYPE enums: LP64 AArch64 relocs.  */

#define R_AARCH64_CALL26        283 /* Likewise for CALL.  */
```

Currently, both of the three symbols `T func`, `U printf`, `U strlen` are unresolved/undetermined, waiting to be relocated/resovled in the link/load stages.
