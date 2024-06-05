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

## entry point

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

## sections2segments

### sections

`rabin2 -S` / `r2 > iS`: sections

- `readelf [-S|--section-headers|--sections]`: Display the sections' header.
- `objdump [-h|--section-headers|--headers]`: Display the contents of the section headers.

```bash
$ radare2.rabin2 -S a.out
[Sections]

nth paddr        size vaddr       vsize perm type        name
―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x00000000    0x0 0x00000000    0x0 ---- NULL
1   0x00000238   0x1b 0x00000238   0x1b -r-- PROGBITS    .interp
2   0x00000254   0x24 0x00000254   0x24 -r-- NOTE        .note.gnu.build-id
3   0x00000278   0x20 0x00000278   0x20 -r-- NOTE        .note.ABI-tag
4   0x00000298   0x1c 0x00000298   0x1c -r-- GNU_HASH    .gnu.hash
5   0x000002b8   0xf0 0x000002b8   0xf0 -r-- DYNSYM      .dynsym
6   0x000003a8   0x92 0x000003a8   0x92 -r-- STRTAB      .dynstr
7   0x0000043a   0x14 0x0000043a   0x14 -r-- GNU_VERSYM  .gnu.version
8   0x00000450   0x30 0x00000450   0x30 -r-- GNU_VERNEED .gnu.version_r
9   0x00000480   0xc0 0x00000480   0xc0 -r-- RELA        .rela.dyn
10  0x00000540   0x78 0x00000540   0x78 -r-- RELA        .rela.plt
11  0x000005b8   0x18 0x000005b8   0x18 -r-x PROGBITS    .init
12  0x000005d0   0x70 0x000005d0   0x70 -r-x PROGBITS    .plt
13  0x00000640  0x13c 0x00000640  0x13c -r-x PROGBITS    .text
14  0x0000077c   0x14 0x0000077c   0x14 -r-x PROGBITS    .fini
15  0x00000790   0x16 0x00000790   0x16 -r-- PROGBITS    .rodata
16  0x000007a8   0x3c 0x000007a8   0x3c -r-- PROGBITS    .eh_frame_hdr
17  0x000007e8   0xac 0x000007e8   0xac -r-- PROGBITS    .eh_frame
18  0x00000d90    0x8 0x00010d90    0x8 -rw- INIT_ARRAY  .init_array
19  0x00000d98    0x8 0x00010d98    0x8 -rw- FINI_ARRAY  .fini_array
20  0x00000da0  0x1f0 0x00010da0  0x1f0 -rw- DYNAMIC     .dynamic
21  0x00000f90   0x70 0x00010f90   0x70 -rw- PROGBITS    .got
22  0x00001000   0x10 0x00011000   0x10 -rw- PROGBITS    .data
23  0x00001010    0x0 0x00011010    0x8 -rw- NOBITS      .bss
24  0x00001010   0x2b 0x00000000   0x2b ---- PROGBITS    .comment
25  0x00001040  0x840 0x00000000  0x840 ---- SYMTAB      .symtab
26  0x00001880  0x22c 0x00000000  0x22c ---- STRTAB      .strtab
27  0x00001aac   0xfa 0x00000000   0xfa ---- STRTAB      .shstrtab
```

### segments

`rabin2 -SS` / `r2 > iSS`: segments

```bash
radare2.rabin2 -SS a.out
[Segments]

nth paddr        size vaddr       vsize perm type name
――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x00000040  0x1f8 0x00000040  0x1f8 -r-- MAP  PHDR
1   0x00000238   0x1b 0x00000238   0x1b -r-- MAP  INTERP
2   0x00000000  0x894 0x00000000  0x894 -r-x MAP  LOAD0
3   0x00000d90  0x280 0x00010d90  0x288 -rw- MAP  LOAD1
4   0x00000da0  0x1f0 0x00010da0  0x1f0 -rw- MAP  DYNAMIC
5   0x00000254   0x44 0x00000254   0x44 -r-- MAP  NOTE
6   0x000007a8   0x3c 0x000007a8   0x3c -r-- MAP  GNU_EH_FRAME
7   0x00000000    0x0 0x00000000    0x0 -rw- MAP  GNU_STACK
8   0x00000d90  0x270 0x00010d90  0x270 -r-- MAP  GNU_RELRO
9   0x00000000   0x40 0x00000000   0x40 -rw- MAP  ehdr

```

### mapping

Use `readelf -S`/`objdump -h` to display the sections' header.

- `readelf [-S|--section-headers]`: display the sections' header
- `objdump [-h|--[section-]headers]`: display the contents of the section headers

Use `readelf -lW` to display the program headers.

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

Also, `rabin2` supports options to list sections and segments and their mapping relationship.

`rabin2 -SSS`: sections mapping to segments.

```bash
$ radare2.rabin2 -SSS a.out
Section to Segment mapping:
Segment      Section
--------------------
PHDR
INTERP       .interp
LOAD0        .interp .note.gnu.build-id .note.ABI-tag .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt .text .fini .rodata .eh_frame_hdr .eh_frame .comment .symtab .strtab .shstrtab
LOAD1        .init_array .fini_array .dynamic .got .data .bss
DYNAMIC      .dynamic
NOTE         .note.gnu.build-id .note.ABI-tag
GNU_EH_FRAME .eh_frame_hdr
GNU_STACK
GNU_RELRO    .init_array .fini_array .dynamic .got
ehdr         .comment
```

From the above output of the section to segment mapping we can see that the sections `.rela.dyn`, `.rela.plt` and `.plt` along with the `.text` have been classified into the first loadable text segment *`LOAD0`*.

Meanwhile, the `.dynamic` and `.got` sections along with the `.data`, `.bss` secitons have been categorized into the second loadable data segment *`LOAD1`*.

As `readelf -lW a.out` indicated, both *LOAD0* and *LOAD1* should be aligned at 0x10000(64K).

1. *LOAD0* is placed at the beginning of the ELF, the zero address is aligned naturally.
2. *LOAD1* contains the sections 18\~23. To satisfy the alignment, vaddr is adjusted with an increment of 0x10000 against paddr.

## dependency

`file`: tests the file in an attempt to classify it.
The output indicates the executable file type and the interpreter.

```bash
$ file a.out
a.out: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=429e4cbff3d62b27c644cef2b8aaf62d380b9690, for GNU/Linux 3.7.0, not stripped
```

On the other hand, the program has called dynamic symbols such as `printf` (fallback to `puts`) which are exported by the dynamic shared library `libc.so`. This means that the DYN PIE ELF depends on `libc.so` to implement its functionality. In other words, there is a dependency that has to be resolved at run time.

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

### dynamic symbol

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

`rabin2 -i `: list symbols imported from libraries.

```bash
$ radare2.rabin2 -i a.out
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

`readelf --dyn-syms`: display the dynamic symbol table.
`objdump [-T|--dynamic-syms]`: display the contents of the dynamic symbol table.

=== "readelf --dyn-syms"

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

=== "objdump -T"

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

## dynamic section

`readelf -x --hex-dump=<number|name>`: dump the contents of section <number|name\> as bytes.
`readelf [-R <number or name>|--relocated-dump=<number or name>]`: dump the relocated contents of section.

- `objdump [-j section|--section=section]`: display information for section name.

### hexdump

For AArch64, the [word size](../cs/machine-word.md) is 8-byte/64-bit, and the [data model](../cs/data-model.md) is typical LP64.

```bash
__SIZEOF_POINTER__=8, __WORDSIZE=64
__SIZEOF_LONG__=8, LONG_BIT=64
```

Reorganize the hexdump format of the `.dynamic` section to display its giant- or double- word array.

```bash
# readelf -R .dynamic a.out
$ dy_offset=$(objdump -hw a.out | awk '/.dynamic/{print "0x"$6}')
$ dy_size=$(objdump -hw a.out | awk '/.dynamic/{print "0x"$3}')
# hexdump -s $dy_offset -n $dy_size -e '"%07.7_ax  " 2/8 "%016x " "\n"' a.out
hexdump -s $dy_offset -n $dy_size -e '"%07.7_ax  " 2/8 "%016x " "\n"' a.out | awk 'BEGIN{print "Offset   GiantWord1       GiantWord2"} 1'
Offset   GiantWord1       GiantWord2
0000da0  0000000000000001 000000000000002d
0000db0  000000000000000c 00000000000005b8
0000dc0  000000000000000d 000000000000077c
0000dd0  0000000000000019 0000000000010d90
0000de0  000000000000001b 0000000000000008
0000df0  000000000000001a 0000000000010d98
0000e00  000000000000001c 0000000000000008
0000e10  000000006ffffef5 0000000000000298
0000e20  0000000000000005 00000000000003a8
0000e30  0000000000000006 00000000000002b8
0000e40  000000000000000a 0000000000000092
0000e50  000000000000000b 0000000000000018
0000e60  0000000000000015 0000000000000000
0000e70  0000000000000003 0000000000010f90
0000e80  0000000000000002 0000000000000078
0000e90  0000000000000014 0000000000000007
0000ea0  0000000000000017 0000000000000540
0000eb0  0000000000000007 0000000000000480
0000ec0  0000000000000008 00000000000000c0
0000ed0  0000000000000009 0000000000000018
0000ee0  000000000000001e 0000000000000008
0000ef0  000000006ffffffb 0000000008000001
0000f00  000000006ffffffe 0000000000000450
0000f10  000000006fffffff 0000000000000001
0000f20  000000006ffffff0 000000000000043a
0000f30  000000006ffffff9 0000000000000004
0000f40  0000000000000000 0000000000000000
*
```

### readelf

`readelf [-d|--dynamic]`: display the dynamic section.

- `PLTGOT`: Address of `.got` section
- `JMPREL`: Address of `.rela.plt` section
- `PLTRELSZ`: size of `.rela.plt` section
- `RELA`: offset of `.rela.dyn` section
- `RELASZ`: size of `.rela.dyn` section
- `RELACOUNT`: count of sections mapped into GNU_RELRO segment

Check readelf's analysis against the raw hexdump above.

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

## relocation entries

Use `readelf` or `objdump` to dump related sections.

```bash
readelf -R .got -R .rela.dyn -R .rela.plt -R .plt a.out
objdump -j .got -j .rela.dyn -j .rela.plt -j .plt -s a.out
```

### hexdump sections

Hexdump contents of RELA section `.got` grouped by giant-word array.

1. 0x10000 is the increment of vaddr over paddr for the LOAD1 segment where the `.got` section is located.
2. 0x5d0 is the address/offset of the `.plt` section located in the LOAD0 segment.

```bash
$ got_offset=$(objdump -hw a.out | awk '/.got/{print "0x"$6}')
$ got_size=$(objdump -hw a.out | awk '/.got/{print "0x"$3}')
$ hexdump -v -s $got_offset -n $got_size -e '"%_ad  " /8 "%016x " "\n"' a.out | awk 'BEGIN{print "Offset    Address           Value"} {printf("%08x  ", $1); printf("%016x  ", $1+0x10000); print $2}'
Offset    Address           Value
00000f90  0000000000010f90  0000000000000000
00000f98  0000000000010f98  0000000000000000
00000fa0  0000000000010fa0  0000000000000000
00000fa8  0000000000010fa8  00000000000005d0
00000fb0  0000000000010fb0  00000000000005d0
00000fb8  0000000000010fb8  00000000000005d0
00000fc0  0000000000010fc0  00000000000005d0
00000fc8  0000000000010fc8  00000000000005d0
00000fd0  0000000000010fd0  0000000000010da0
00000fd8  0000000000010fd8  0000000000000000
00000fe0  0000000000010fe0  0000000000000000
00000fe8  0000000000010fe8  0000000000000000
00000ff0  0000000000010ff0  0000000000000754
00000ff8  0000000000010ff8  0000000000000000
```

Hexdump contents of RELA section `.rela.plt` grouped by giant-word array.

> Pay attention to the first giant-word: it points to `.got` entry.

```bash
$ rp_offset=$(objdump -hw a.out | awk '/.rela.plt/{print "0x"$6}')
$ rp_size=$(objdump -hw a.out | awk '/.rela.plt/{print "0x"$3}')
$ hexdump -v -s $rp_offset -n $rp_size -e '"%07.7_ax  " 3/8 "%016x " "\n"' a.out
0000540  0000000000010fa8 0000000300000402 0000000000000000
0000558  0000000000010fb0 0000000500000402 0000000000000000
0000570  0000000000010fb8 0000000600000402 0000000000000000
0000588  0000000000010fc0 0000000700000402 0000000000000000
00005a0  0000000000010fc8 0000000800000402 0000000000000000
```

Hexdump contents of RELA section `.rela.dyn` grouped by giant-word array:

> Pay attention to the first giant-word: it points to `.got` entry.

```bash
$ rd_offset=$(objdump -hw a.out | awk '/.rela.dyn/{print "0x"$6}')
$ rd_size=$(objdump -hw a.out | awk '/.rela.dyn/{print "0x"$3}')
$ hexdump -v -s $rd_offset -n $rd_size -e '"%07.7_ax  " 3/8 "%016x " "\n"' a.out
0000480  0000000000010d90 0000000000000403 0000000000000750 # .init_array
0000498  0000000000010d98 0000000000000403 0000000000000700 # .fini_array
00004b0  0000000000010ff0 0000000000000403 0000000000000754 # GOT 
00004c8  0000000000011008 0000000000000403 0000000000011008 # .data[1]
00004e0  0000000000010fd8 0000000400000401 0000000000000000 # GOT 
00004f8  0000000000010fe0 0000000500000401 0000000000000000 # GOT 
0000510  0000000000010fe8 0000000600000401 0000000000000000 # GOT 
0000528  0000000000010ff8 0000000900000401 0000000000000000 # GOT 
```

00004c8 - 0000000000011008: the second giant word of `.data`(Offset=0x001000, Address=0x0011000 Size=0x000010), can be denoted as .data[1] under AArch64.

```bash
$ readelf -x .data a.out

Hex dump of section '.data':
  0x00011000 00000000 00000000 08100100 00000000 ................

$ objdump -j .data -s a.out

a.out:     file format elf64-littleaarch64

Contents of section .data:
 11000 00000000 00000000 08100100 00000000  ................
```

Customise the hexdump format to be more readable.

```bash
$ d_offset=$(objdump -hw a.out | awk '/\.data/ && !/\.nodata/ {print "0x"$6}')
$ d_size=$(objdump -hw a.out | awk '/\.data/ && !/\.nodata/ {print "0x"$3}')
$ hexdump -v -s $d_offset -n $d_size -e '"%07.7_ax  " 2/8 "%016x " "\n"' a.out
0001000  0000000000000000 0000000000011008
```

### readelf/objdump

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
$ radare2.rabin2 -R a.out

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

If you only want to disassemble the `puts@plt` symbol, not the whole section, you should specify an address range for objdump.

As a immature semi-solution, try the following commands.

```bash
$ puts_plt=$(radare2.rabin2 -i a.out | awk '/puts/ {print $2}')
$ objdump -d --start-address=$puts_plt --stop-address=$((puts_plt+20)) a.out

a.out:     file format elf64-littleaarch64


Disassembly of section .plt:

0000000000000630 <puts@plt>:
 630:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf770>
 634:	f947e611 	ldr	x17, [x16, #4040]
 638:	913f2210 	add	x16, x16, #0xfc8
 63c:	d61f0220 	br	x17

Disassembly of section .text:

0000000000000640 <_start>:
 640:	d503201f 	nop
```

As we can see, 0x10000+0xfc8 is the offset of `puts` in `.rela.plt` entries of `readelf -r a.out` and relocation records of `objdump -R a.out`.

The output of `rabin2 -R a.out` maybe more clear: the vaddr=0x00010fc8 is relative to virtual baddr, while the paddr=0x00000fc8 is relative to physical segment.

### ADRP/LDR

Line 40 `adrp x16, 10000` is used to form PC-relative address to 4KB page.

> PLS refer to [ARM ADRP and ADRL pseudo-instruction](../arm/arm-adrp-adrl.md) and [ARM ADR/ADRP demos](../arm/arm-adr-demo.md).

According to the [A64 ADRP](https://developer.arm.com/documentation/ddi0602/2024-03/Base-Instructions/ADRP--Form-PC-relative-address-to-4KB-page-?lang=en) instruction specification, we can analyse the opcode using the following Python code snippets.

```Python title="ADRP immediate analysis"
opcode=0x90000090
#format(opcode, '032b')
#f'{opcode=:#032b}'

immlo_mask=(1<<30)|(1<<29)
# f'{immlo_mask=:032b}'
immhi_mask=(2**24-1)&(~(2**5-1))
# f'{immhi_mask=:032b}'

immlo=((opcode&immlo_mask)<<1)>>30
# f'immlo: {immlo=:02b}'
immhi=(opcode&immhi_mask)>>5
# f'immhi: {immhi=:019b}'

imm=(immhi<<2|immlo)<<12
f'{imm=:#8x}'
```

It outputs `'imm= 0x10000'`. That's the PC-relative literal that encoded in the ADRP instruction.

Line 41\~42 is equivalent expansion of pre-indexing addressing instruction `ldr x17, [x16, #0xfc8]!`.

In the following articles we'll see the crucial role of the offset in resolving `puts@plt` to real `puts` using `.rela.plt` and `.got`.
