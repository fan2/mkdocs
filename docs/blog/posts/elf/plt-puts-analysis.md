---
title: puts@plt - static analysis
authors:
    - xman
date:
    created: 2023-06-28T10:00:00
categories:
    - elf
tags:
    - PLT
    - GOT
comments: true
---

So far we've been through the [default gcc compilation process](./gcc-compilation-dynamic.md) and had a look at [the product of our C demo program](./elf-dyn-tour.md) `a.out` with [GNU binutils](./gnu-binutils.md).

It links dynamically by default, a dynamic linker (aka interpreter) is used to resolve the final dependencies on dynamic libraries when the executable is loaded into memory to run.

In this article I'll have a look at how the shared dynamic symbol such as `puts` is designated at link time in the DYN PIE ELF.

<!-- more -->

## needed dependency

As shown below, the DYN PIE ELF `a.out` has linked `libc.so`.
This means that it needs `libc.so` as a dependency to run properly.

```bash
pwndbg> !readelf -d a.out | head -4

Dynamic section at offset 0xda0 contains 27 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]

pwndbg> !objdump -x a.out | sed -n '/Dynamic Section/{N;p}'
Dynamic Section:
  NEEDED               libc.so.6

pwndbg> !radare2.rabin2 -l a.out
[Linked libraries]
libc.so.6

1 library
```

## entry point paddr

`file`: tests the file in an attempt to classify it.
The output indicates the executable file type and the interpreter.

```bash
$ file a.out
a.out: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=429e4cbff3d62b27c644cef2b8aaf62d380b9690, for GNU/Linux 3.7.0, not stripped
```

`objdump [-f|--file-headers]`: display the contents of the overall file header.
The output indicates the file type and the start logic address.

```bash
$ objdump -f a.out

a.out:     file format elf64-littleaarch64
architecture: aarch64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x0000000000000640
```

`readelf  [-h|--file-header]`: display the ELF file header.
The output extracts full binary information from the ELF header.

```bash
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

rabin2's `-e` option can be used to list entrypoints:

`-e`: program entrypoint
`-ee`: constructor/destructor entrypoints

```bash
$ radare2.rabin2 -eee a.out
[Entrypoints]
vaddr=0x00000640 paddr=0x00000640 haddr=0x00000018 hvaddr=0x00000018 type=program

1 entrypoints
[Constructors]
vaddr=0x00000750 paddr=0x00000750 hvaddr=0x00010d90 hpaddr=0x00000d90 type=init
vaddr=0x00000700 paddr=0x00000700 hvaddr=0x00010d98 hpaddr=0x00000d98 type=fini

2 entrypoints
```

You can extract the address of the entry point by means of one of the following commands.

```bash
radare2.rabin2 -eq a.out
objdump -f a.out | sed -n 's/^start address //p'
objdump -f a.out | awk '/start address/ {print $NF}'
readelf -h a.out | sed -n 's/.*Entry point address:\s*//p'
readelf -h a.out | awk '/Entry point address/ {print $NF}'
```

## dynamic section

`readelf [-d|--dynamic]`: display the dynamic section.

- `PLTGOT`: start of `.got` section
- `JMPREL`: offset of `.rela.plt` section
- `PLTRELSZ`: size of `.rela.plt` section
- `RELA`: offset of `.rela.dyn` section
- `RELASZ`: size of `.rela.dyn` section
- `RELACOUNT`: count of sections mapped into GNU_RELRO segment

```bash
$ readelf -d a.out

Dynamic section at offset 0xda0 contains 27 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000c (INIT)               0x5b8
 0x000000000000000d (FINI)               0x77c
 0x0000000000000019 (INIT_ARRAY)         0x10d90
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x10d98
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x298
 0x0000000000000005 (STRTAB)             0x3a8
 0x0000000000000006 (SYMTAB)             0x2b8
 0x000000000000000a (STRSZ)              146 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000015 (DEBUG)              0x0
 0x0000000000000003 (PLTGOT)             0x10f90
 0x0000000000000002 (PLTRELSZ)           120 (bytes)
 0x0000000000000014 (PLTREL)             RELA
 0x0000000000000017 (JMPREL)             0x540
 0x0000000000000007 (RELA)               0x480
 0x0000000000000008 (RELASZ)             192 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000000000001e (FLAGS)              BIND_NOW
 0x000000006ffffffb (FLAGS_1)            Flags: NOW PIE
 0x000000006ffffffe (VERNEED)            0x450
 0x000000006fffffff (VERNEEDNUM)         1
 0x000000006ffffff0 (VERSYM)             0x43a
 0x000000006ffffff9 (RELACOUNT)          4
 0x0000000000000000 (NULL)               0x0
```

## dynamic symbol

`nm -D|--dynamic`: display dynamic symbols instead of normal symbols.

```bash
$ nm -D a.out
                 U abort@GLIBC_2.17
                 w __cxa_finalize@GLIBC_2.17
                 w __gmon_start__
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
                 U __libc_start_main@GLIBC_2.34
                 U puts@GLIBC_2.17
```

`readelf --dyn-syms`: display the dynamic symbol table.

```bash
$ readelf --dyn-syms a.out

Symbol table '.dynsym' contains 10 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 00000000000005b8     0 SECTION LOCAL  DEFAULT   11 .init
     2: 0000000000011000     0 SECTION LOCAL  DEFAULT   22 .data
     3: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND _[...]@GLIBC_2.34 (2)
     4: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_deregisterT[...]
     5: 0000000000000000     0 FUNC    WEAK   DEFAULT  UND _[...]@GLIBC_2.17 (3)
     6: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__
     7: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND abort@GLIBC_2.17 (3)
     8: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND puts@GLIBC_2.17 (3)
     9: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_registerTMC[...]
```

`objdump [-T|--dynamic-syms]`: display the contents of the dynamic symbol table.

```bash
$ objdump -T a.out

a.out:     file format elf64-littleaarch64

DYNAMIC SYMBOL TABLE:
00000000000005b8 l    d  .init	0000000000000000              .init
0000000000011000 l    d  .data	0000000000000000              .data
0000000000000000      DF *UND*	0000000000000000 (GLIBC_2.34) __libc_start_main
0000000000000000  w   D  *UND*	0000000000000000  Base        _ITM_deregisterTMCloneTable
0000000000000000  w   DF *UND*	0000000000000000 (GLIBC_2.17) __cxa_finalize
0000000000000000  w   D  *UND*	0000000000000000  Base        __gmon_start__
0000000000000000      DF *UND*	0000000000000000 (GLIBC_2.17) abort
0000000000000000      DF *UND*	0000000000000000 (GLIBC_2.17) puts
0000000000000000  w   D  *UND*	0000000000000000  Base        _ITM_registerTMCloneTable
```

`rabin2 -i `: list symbols imported from libraries.

```bash
$ rabin2 -i a.out
[Imports]
nth vaddr      bind   type   lib name
―――――――――――――――――――――――――――――――――――――
3   0x000005f0 GLOBAL FUNC       __libc_start_main
4   ---------- WEAK   NOTYPE     _ITM_deregisterTMCloneTable
5   0x00000600 WEAK   FUNC       __cxa_finalize
6   0x00000610 WEAK   NOTYPE     __gmon_start__
7   0x00000620 GLOBAL FUNC       abort
8   0x00000630 GLOBAL FUNC       puts
9   ---------- WEAK   NOTYPE     _ITM_registerTMCloneTable
```

## relocation entries

`readelf [-r|--relocs]`: display the relocations.

```bash
$ readelf -r a.out

Relocation section '.rela.dyn' at offset 0x480 contains 8 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000010d90  000000000403 R_AARCH64_RELATIV                    750
000000010d98  000000000403 R_AARCH64_RELATIV                    700
000000010ff0  000000000403 R_AARCH64_RELATIV                    754
000000011008  000000000403 R_AARCH64_RELATIV                    11008
000000010fd8  000400000401 R_AARCH64_GLOB_DA 0000000000000000 _ITM_deregisterTM[...] + 0
000000010fe0  000500000401 R_AARCH64_GLOB_DA 0000000000000000 __cxa_finalize@GLIBC_2.17 + 0
000000010fe8  000600000401 R_AARCH64_GLOB_DA 0000000000000000 __gmon_start__ + 0
000000010ff8  000900000401 R_AARCH64_GLOB_DA 0000000000000000 _ITM_registerTMCl[...] + 0

Relocation section '.rela.plt' at offset 0x540 contains 5 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000010fa8  000300000402 R_AARCH64_JUMP_SL 0000000000000000 __libc_start_main@GLIBC_2.34 + 0
000000010fb0  000500000402 R_AARCH64_JUMP_SL 0000000000000000 __cxa_finalize@GLIBC_2.17 + 0
000000010fb8  000600000402 R_AARCH64_JUMP_SL 0000000000000000 __gmon_start__ + 0
000000010fc0  000700000402 R_AARCH64_JUMP_SL 0000000000000000 abort@GLIBC_2.17 + 0
000000010fc8  000800000402 R_AARCH64_JUMP_SL 0000000000000000 puts@GLIBC_2.17 + 0
```

`objdump [-r|--reloc]`: display the relocation entries in the file.

```bash
$ objdump -r a.out

a.out:     file format elf64-littleaarch64

```

`objdump [-R|--dynamic-reloc]`: display the dynamic relocation entries in the file.

> Almost the same as `readelf -r a.out`, but the full TYPE name is visible.

```bash
[0xffff880e5c40]> !objdump -R a.out

a.out:     file format elf64-littleaarch64

DYNAMIC RELOCATION RECORDS
OFFSET           TYPE              VALUE
0000000000010d90 R_AARCH64_RELATIVE  *ABS*+0x0000000000000750
0000000000010d98 R_AARCH64_RELATIVE  *ABS*+0x0000000000000700
0000000000010ff0 R_AARCH64_RELATIVE  *ABS*+0x0000000000000754
0000000000011008 R_AARCH64_RELATIVE  *ABS*+0x0000000000011008
0000000000010fd8 R_AARCH64_GLOB_DAT  _ITM_deregisterTMCloneTable@Base
0000000000010fe0 R_AARCH64_GLOB_DAT  __cxa_finalize@GLIBC_2.17
0000000000010fe8 R_AARCH64_GLOB_DAT  __gmon_start__@Base
0000000000010ff8 R_AARCH64_GLOB_DAT  _ITM_registerTMCloneTable@Base
0000000000010fa8 R_AARCH64_JUMP_SLOT  __libc_start_main@GLIBC_2.34
0000000000010fb0 R_AARCH64_JUMP_SLOT  __cxa_finalize@GLIBC_2.17
0000000000010fb8 R_AARCH64_JUMP_SLOT  __gmon_start__@Base
0000000000010fc0 R_AARCH64_JUMP_SLOT  abort@GLIBC_2.17
0000000000010fc8 R_AARCH64_JUMP_SLOT  puts@GLIBC_2.17
```

`rabin2 -R`: list the relocations.

```bash
$ rabin2 -R a.out

[Relocations]

vaddr      paddr      type   ntype name
―――――――――――――――――――――――――――――――――――――――
0x00010d90 0x00000d90 ADD_64 1027   0x00000750
0x00010d98 0x00000d98 ADD_64 1027   0x00000700
0x00010fa8 0x00000fa8 SET_64 1026  __libc_start_main
0x00010fb0 0x00000fb0 SET_64 1026  __cxa_finalize
0x00010fb8 0x00000fb8 SET_64 1026  __gmon_start__
0x00010fc0 0x00000fc0 SET_64 1026  abort
0x00010fc8 0x00000fc8 SET_64 1026  puts
0x00010fd8 0x00000fd8 SET_64 1025  _ITM_deregisterTMCloneTable
0x00010fe0 0x00000fe0 SET_64 1025  __cxa_finalize
0x00010fe8 0x00000fe8 SET_64 1025  __gmon_start__
0x00010ff0 0x00000ff0 ADD_64 1027   0x00000754
0x00010ff8 0x00000ff8 SET_64 1025  _ITM_registerTMCloneTable
0x00011008 0x00001008 ADD_64 1027   0x00011008
```

## dump .got & .plt

`readelf -x --hex-dump=<number|name>`: dump the contents of section <number|name\> as bytes.
`readelf [-R <number or name>|--relocated-dump=<number or name>]`: dump the relocated contents of section.

```bash
# readelf -x .plt -x .got -x .rela.plt a.out
$ readelf -R .plt -R .got -R .rela.plt a.out

Hex dump of section '.rela.plt':
  0x00000540 a80f0100 00000000 02040000 03000000 ................
  0x00000550 00000000 00000000 b00f0100 00000000 ................
  0x00000560 02040000 05000000 00000000 00000000 ................
  0x00000570 b80f0100 00000000 02040000 06000000 ................
  0x00000580 00000000 00000000 c00f0100 00000000 ................
  0x00000590 02040000 07000000 00000000 00000000 ................
  0x000005a0 c80f0100 00000000 02040000 08000000 ................
  0x000005b0 00000000 00000000                   ........


Hex dump of section '.plt':
  0x000005d0 f07bbfa9 90000090 11d247f9 10823e91 .{........G...>.
  0x000005e0 20021fd6 1f2003d5 1f2003d5 1f2003d5  .... ... ... ..
  0x000005f0 90000090 11d647f9 10a23e91 20021fd6 ......G...>. ...
  0x00000600 90000090 11da47f9 10c23e91 20021fd6 ......G...>. ...
  0x00000610 90000090 11de47f9 10e23e91 20021fd6 ......G...>. ...
  0x00000620 90000090 11e247f9 10023f91 20021fd6 ......G...?. ...
  0x00000630 90000090 11e647f9 10223f91 20021fd6 ......G.."?. ...


Hex dump of section '.got':
  0x00010f90 00000000 00000000 00000000 00000000 ................
  0x00010fa0 00000000 00000000 d0050000 00000000 ................
  0x00010fb0 d0050000 00000000 d0050000 00000000 ................
  0x00010fc0 d0050000 00000000 d0050000 00000000 ................
  0x00010fd0 a00d0100 00000000 00000000 00000000 ................
  0x00010fe0 00000000 00000000 00000000 00000000 ................
  0x00010ff0 54070000 00000000 00000000 00000000 T...............

```

`objdump [-j section|--section=section]`: display information for section name.

```bash
$ objdump -j .plt -j .got -j .rela.plt -s a.out

a.out:     file format elf64-littleaarch64

Contents of section .rela.plt:
 0540 a80f0100 00000000 02040000 03000000  ................
 0550 00000000 00000000 b00f0100 00000000  ................
 0560 02040000 05000000 00000000 00000000  ................
 0570 b80f0100 00000000 02040000 06000000  ................
 0580 00000000 00000000 c00f0100 00000000  ................
 0590 02040000 07000000 00000000 00000000  ................
 05a0 c80f0100 00000000 02040000 08000000  ................
 05b0 00000000 00000000                    ........
Contents of section .plt:
 05d0 f07bbfa9 90000090 11d247f9 10823e91  .{........G...>.
 05e0 20021fd6 1f2003d5 1f2003d5 1f2003d5   .... ... ... ..
 05f0 90000090 11d647f9 10a23e91 20021fd6  ......G...>. ...
 0600 90000090 11da47f9 10c23e91 20021fd6  ......G...>. ...
 0610 90000090 11de47f9 10e23e91 20021fd6  ......G...>. ...
 0620 90000090 11e247f9 10023f91 20021fd6  ......G...?. ...
 0630 90000090 11e647f9 10223f91 20021fd6  ......G.."?. ...
Contents of section .got:
 10f90 00000000 00000000 00000000 00000000  ................
 10fa0 00000000 00000000 d0050000 00000000  ................
 10fb0 d0050000 00000000 d0050000 00000000  ................
 10fc0 d0050000 00000000 d0050000 00000000  ................
 10fd0 a00d0100 00000000 00000000 00000000  ................
 10fe0 00000000 00000000 00000000 00000000  ................
 10ff0 54070000 00000000 00000000 00000000  T...............
```

## disassemble .plt

Statically disassemble the `.plt` section:

```bash linenums="1" hl_lines="39-43"
# objdump -Rd a.out : disassemble all
$ objdump -j .plt -d a.out
Disassembly of section .plt:

00000000000005d0 <.plt>:
 5d0:	a9bf7bf0 	stp	x16, x30, [sp, #-16]!
 5d4:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf770>
 5d8:	f947d211 	ldr	x17, [x16, #4000]
 5dc:	913e8210 	add	x16, x16, #0xfa0
 5e0:	d61f0220 	br	x17
 5e4:	d503201f 	nop
 5e8:	d503201f 	nop
 5ec:	d503201f 	nop

00000000000005f0 <__libc_start_main@plt>:
 5f0:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf770>
 5f4:	f947d611 	ldr	x17, [x16, #4008]
 5f8:	913ea210 	add	x16, x16, #0xfa8
 5fc:	d61f0220 	br	x17

0000000000000600 <__cxa_finalize@plt>:
 600:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf770>
 604:	f947da11 	ldr	x17, [x16, #4016]
 608:	913ec210 	add	x16, x16, #0xfb0
 60c:	d61f0220 	br	x17

0000000000000610 <__gmon_start__@plt>:
 610:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf770>
 614:	f947de11 	ldr	x17, [x16, #4024]
 618:	913ee210 	add	x16, x16, #0xfb8
 61c:	d61f0220 	br	x17

0000000000000620 <abort@plt>:
 620:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf770>
 624:	f947e211 	ldr	x17, [x16, #4032]
 628:	913f0210 	add	x16, x16, #0xfc0
 62c:	d61f0220 	br	x17

0000000000000630 <puts@plt>:
 630:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf770>
 634:	f947e611 	ldr	x17, [x16, #4040]
 638:	913f2210 	add	x16, x16, #0xfc8
 63c:	d61f0220 	br	x17

$ radare2.rax2 4040
0xfc8
```

As we can see, 0x10000+0xfc8 is the offset of `puts` in `.rela.plt` entries of `readelf -r a.out` and relocation records of `objdump -R a.out`.

The output of `rabin2 -R a.out` maybe more clear: the vaddr=0x00010fc8 is relative to virtual baddr, while the paddr=0x00000fc8 is relative to physical segment.

Line 41\~42 is equivalent expansion of pre-indexing addressing instruction `ldr x17, [x16, #0xfc8]!`.
