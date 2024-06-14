---
title: puts@plt/rela/got - static analysis
authors:
    - xman
date:
    created: 2023-06-28T10:00:00
categories:
    - elf
tags:
    - .dynamic
    - .dynstr
    - .dynsym
    - .rela.plt
    - .got
    - .plt
comments: true
---

So far we've been through the [default gcc compilation process](./gcc-compilation-dynamic.md) and had a look at [the product of our C demo program](./elf-dyn-tour.md) `a.out` with [GNU binutils](./gnu-binutils.md).

It links dynamically by default, a dynamic linker (aka interpreter) is used to resolve the final dependencies on dynamic libraries when the executable is loaded into memory to run.

In this article I'll have a look at how the shared dynamic symbol such as `puts` is designated at link time in the DYN PIE ELF.

<!-- more -->

## dependency

`file`: tests the file in an attempt to classify it.

```bash
$ file a.out
a.out: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=429e4cbff3d62b27c644cef2b8aaf62d380b9690, for GNU/Linux 3.7.0, not stripped
```
The output indicates the executable file type and the interpreter.

```bash
$ readelf -p .interp a.out

String dump of section '.interp':
  [     0]  /lib/ld-linux-aarch64.so.1

```

On the other hand, the program has called dynamic symbols such as `printf` (optimized out va_list without format specifier, fallback to `puts`) which are exported by the dynamic shared library `libc.so`. This means that the DYN PIE ELF depends on `libc.so` to implement its functionality. In other words, there is a dependency that has to be resolved at run time.

```bash
$ readelf -d a.out | head -4

Dynamic section at offset 0xda0 contains 27 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]

$ objdump -x a.out | sed -n '/Dynamic Section/{N;p}'
Dynamic Section:
  NEEDED               libc.so.6

$ rabin2 -l a.out
[Linked libraries]
libc.so.6

1 library
```

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
$ rabin2 -eee a.out
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
rabin2 -eq a.out
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
$ rabin2 -S a.out
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
rabin2 -SS a.out
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

!!! note "ld -z relro"

    GCC Compilation Quick Tour - [dynamic](../elf/gcc-compilation-dynamic.md)/[static](../elf/gcc-compilation-static.md): [collect2](https://gcc.gnu.org/onlinedocs/gccint/Collect2.html)/[LD](https://sourceware.org/binutils/docs/ld/Options.html) `-z relro`

    Create an ELF `PT_GNU_RELRO` segment header in the object. This specifies a memory segment that should be made read-only after relocation, if supported.

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
$ rabin2 -SSS a.out
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

From the above output of the section to segment mapping we can see that the ALLOC|LOAD|READONLY CONTENTS(CODE or DATA) sections `.rela.dyn`, `.rela.plt` and `.plt` along with the `.text` have been classified into the first loadable text segment *`LOAD0`*.

> The `.comment`, `.symtab`, `.strtab`, `.shstrtab` sections are counted in the LOAD0 segment?

Otherwise, the ALLOC but not READONLY sections `.dynamic` and `.got` along with the `.data` and `.bss` secitons have been categorized into the second loadable data segment *`LOAD1`*.

As `readelf -lW a.out` indicated, both *LOAD0* and *LOAD1* should be aligned at 0x10000(64K).

1. *LOAD0* is placed at the beginning of the ELF, the zero address is aligned naturally.
2. *LOAD1* contains the sections 18\~23. To satisfy the alignment, vaddr is adjusted with an increment of 0x10000 against paddr.

## dynamic section

Refer to [TIS - ELF v1.2](https://refspecs.linuxfoundation.org/elf/elf.pdf) | Book III: SYSV - 2. Program Loading and Dynamic Linking - Dynamic Linking - Dynamic Section.

```c title="Dynamic section entry"
// /usr/include/elf.h

typedef uint64_t Elf64_Xword;
typedef int64_t  Elf64_Sxword;
typedef uint64_t Elf64_Addr;

typedef struct
{
  Elf64_Sxword  d_tag;          /* Dynamic entry type */
  union
    {
      Elf64_Xword d_val;        /* Integer value */
      Elf64_Addr d_ptr;         /* Address value */
    } d_un;
} Elf64_Dyn;
```

Legal values for `d_tag` (dynamic entry type):

```c title="elf.h - d_tag"
#define DT_NULL     0       /* Marks end of dynamic section */
#define DT_NEEDED   1       /* Name of needed library */
#define DT_PLTRELSZ 2       /* Size in bytes of PLT relocs */
#define DT_PLTGOT   3       /* Processor defined value */
#define DT_HASH     4       /* Address of symbol hash table */
#define DT_STRTAB   5       /* Address of string table */
#define DT_SYMTAB   6       /* Address of symbol table */
#define DT_RELA     7       /* Address of Rela relocs */
#define DT_RELASZ   8       /* Total size of Rela relocs */
#define DT_RELAENT  9       /* Size of one Rela reloc */
#define DT_STRSZ    10      /* Size of string table */
#define DT_SYMENT   11      /* Size of one symbol table entry */
#define DT_INIT     12      /* Address of init function */
#define DT_FINI     13      /* Address of termination function */
#define DT_SONAME   14      /* Name of shared object */
#define DT_RPATH    15      /* Library search path (deprecated) */
#define DT_SYMBOLIC 16      /* Start symbol search here */
#define DT_REL      17      /* Address of Rel relocs */
#define DT_RELSZ    18      /* Total size of Rel relocs */
#define DT_RELENT   19      /* Size of one Rel reloc */
#define DT_PLTREL   20      /* Type of reloc in PLT */
#define DT_DEBUG    21      /* For debugging; unspecified */
#define DT_TEXTREL  22      /* Reloc might modify .text */
#define DT_JMPREL   23      /* Address of PLT relocs */
#define DT_BIND_NOW 24      /* Process relocations of object */
#define DT_INIT_ARRAY   25      /* Array with addresses of init fct */
#define DT_FINI_ARRAY   26      /* Array with addresses of fini fct */
#define DT_INIT_ARRAYSZ 27      /* Size in bytes of DT_INIT_ARRAY */
#define DT_FINI_ARRAYSZ 28      /* Size in bytes of DT_FINI_ARRAY */
#define DT_RUNPATH  29      /* Library search path */
#define DT_FLAGS    30      /* Flags for the object being loaded */

/* The versioning entry types.  The next are defined as part of the
   GNU extension.  */
#define DT_VERSYM   0x6ffffff0

#define DT_RELACOUNT    0x6ffffff9
#define DT_RELCOUNT 0x6ffffffa

/* These were chosen by Sun.  */
#define DT_FLAGS_1  0x6ffffffb  /* State flags, see DF_1_* below.  */
#define DT_VERDEF   0x6ffffffc  /* Address of version definition
                       table */
```

---

`readelf -x --hex-dump=<number|name>`: dump the contents of section <number|name\> as bytes.
`readelf [-R <number or name>|--relocated-dump=<number or name>]`: dump the relocated contents of section.

- `objdump [-j section|--section=section]`: display information for section name.

### hexdump

For AArch64, the [word size](../cs/machine-word.md) is 8-byte/64-bit, and the [data model](../cs/data-model.md) is typical LP64.

```bash
__SIZEOF_POINTER__=8, __WORDSIZE=64
__SIZEOF_LONG__=8, LONG_BIT=64
```

As we can see, the two fields of `Elf64_Dyn` are all 64-bit, so reorganize the hexdump format to display its giant- or double- word array accordingly.

> 65536/0x10000 is the increment of vaddr over paddr for the LOAD1 segment where the `.dynamic` section is located.

```bash
# readelf -R .dynamic a.out
# dy_offset=$(rabin2 -S a.out | awk '/.dynamic/{print $2}')
# dy_offset=$(rabin2 -S a.out | awk '/.dynamic/{print $3}')
$ dy_offset=$(objdump -hw a.out | awk '/.dynamic/{print "0x"$6}')
$ dy_size=$(objdump -hw a.out | awk '/.dynamic/{print "0x"$3}')
# hexdump -s $dy_offset -n $dy_size -e '"%07.7_ax  " 2/8 "%016x " "\n"' a.out
$ hexdump -v -s $dy_offset -n $dy_size -e '"%08_ax\t" 2/8 "%016x\t" "\n"' a.out \
| awk 'BEGIN{print "offset\t\taddress\t\t\t\td_tag\t\t\t\td_un"} \
{printf("%s\t", $1); printf("%016x\t", (("0x"$1))+65536); printf("%s\t", $2); print $3}'
offset		address				d_tag				d_un
00000da0	0000000000010da0	0000000000000001	000000000000002d
00000db0	0000000000010db0	000000000000000c	00000000000005b8
00000dc0	0000000000010dc0	000000000000000d	000000000000077c
00000dd0	0000000000010dd0	0000000000000019	0000000000010d90
00000de0	0000000000010de0	000000000000001b	0000000000000008
00000df0	0000000000010df0	000000000000001a	0000000000010d98
00000e00	0000000000010e00	000000000000001c	0000000000000008
00000e10	0000000000010e10	000000006ffffef5	0000000000000298
00000e20	0000000000010e20	0000000000000005	00000000000003a8
00000e30	0000000000010e30	0000000000000006	00000000000002b8
00000e40	0000000000010e40	000000000000000a	0000000000000092
00000e50	0000000000010e50	000000000000000b	0000000000000018
00000e60	0000000000010e60	0000000000000015	0000000000000000
00000e70	0000000000010e70	0000000000000003	0000000000010f90
00000e80	0000000000010e80	0000000000000002	0000000000000078
00000e90	0000000000010e90	0000000000000014	0000000000000007
00000ea0	0000000000010ea0	0000000000000017	0000000000000540
00000eb0	0000000000010eb0	0000000000000007	0000000000000480
00000ec0	0000000000010ec0	0000000000000008	00000000000000c0
00000ed0	0000000000010ed0	0000000000000009	0000000000000018
00000ee0	0000000000010ee0	000000000000001e	0000000000000008
00000ef0	0000000000010ef0	000000006ffffffb	0000000008000001
00000f00	0000000000010f00	000000006ffffffe	0000000000000450
00000f10	0000000000010f10	000000006fffffff	0000000000000001
00000f20	0000000000010f20	000000006ffffff0	000000000000043a
00000f30	0000000000010f30	000000006ffffff9	0000000000000004
00000f40	0000000000010f40	0000000000000000	0000000000000000
00000f50	0000000000010f50	0000000000000000	0000000000000000
00000f60	0000000000010f60	0000000000000000	0000000000000000
00000f70	0000000000010f70	0000000000000000	0000000000000000
00000f80	0000000000010f80	0000000000000000	0000000000000000
```

### readelf

`readelf [-d|--dynamic]`: display the dynamic section.

```bash
$ readelf -d a.out

Dynamic section at offset 0xda0 contains 27 entries:
 Tag                Type                 Name/Value
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

Check readelf's analysis against the raw hexdump above and the sections dumped by `rabin2 -S a.out`.

1. `DT_NEEDED`(0x0000000000000001)=0x2d: offset in STRTAB `.dynstr`, points to `libc.so.6`.
2. `DT_STRTAB`(0000000000000005)=0x3a8: address of section `.dynstr`.
3. `DT_SYMTAB`(0000000000000006)=0x2b8: address of section `.dynsym`.
4. `DT_STRSZ`(000000000000000a)=0x92/146 - size of section `.dynstr`.
5. `DT_SYMENT`(000000000000000b)=0x18/24 - size of one symbol table entry (of `.dynsym`)
5. `DT_PLTGOT`(0000000000000003)=0x10f90: address of section `.got`
6. `DT_PLTRELSZ`(0000000000000002)=0x78/120 - size of section `.rela.plt`
7. `DT_PLTREL`(0000000000000014)=0x7/`DT_RELA`: Type of reloc in PLT, `DT_REL` as alternate.
8. `DT_JMPREL`(0000000000000017)=0x540: address of section `.rela.plt`.
9. `DT_RELA`(0000000000000007)=0x480: address of section `.rela.dyn`.
10. `DT_RELASZ`(0000000000000008)=0xc0/192 - size of section `.rela.dyn`.
11. `DT_RELAENT`(0000000000000009)=0x18/24 - size of one relocation entry of `DT_RELA`.
12. `DT_RELACOUNT`(000000006ffffff9)=0x4: count of sections mapped into `GNU_RELRO` segment?
13. `DT_FLAGS`(000000000000001e)=0x8/`DF_BIND_NOW`: No lazy binding for this object.
14. `DT_FLAGS_1`(000000006ffffffb)=0x1/`DF_1_NOW`: Set RTLD_NOW for this object.

!!! note "ld -z now"

    [GCC Compilation Quick Tour - dynamic](../elf/gcc-compilation-dynamic.md): [collect2](https://gcc.gnu.org/onlinedocs/gccint/Collect2.html)/[LD](https://sourceware.org/binutils/docs/ld/Options.html) `-z now`

    When generating an executable or shared library, mark it to tell the dynamic linker to *resolve* all symbols when the program is started, or when the shared library is loaded by [dlopen](https://www.gnu.org/savannah-checkouts/gnu/gnulib/manual/html_node/dlopen.html), instead of deferring function call resolution to the point when the function is first called.

## dynamic symbol

```c title="Symbol table entry"
// /usr/include/elf.h

typedef uint32_t Elf64_Word;
typedef uint16_t Elf64_Section;

typedef struct
{
  Elf64_Word    st_name;        /* Symbol name (string tbl index) */
  unsigned char st_info;        /* Symbol type and binding */
  unsigned char st_other;       /* Symbol visibility */
  Elf64_Section st_shndx;       /* Section index */
  Elf64_Addr    st_value;       /* Symbol value */
  Elf64_Xword   st_size;        /* Symbol size */
} Elf64_Sym;

typedef struct
{
  Elf64_Half si_boundto;        /* Direct bindings, symbol bound to */
  Elf64_Half si_flags;          /* Per symbol flags */
} Elf64_Syminfo;

/* How to extract and insert information held in the st_info field.  */

#define ELF32_ST_BIND(val)      (((unsigned char) (val)) >> 4)
#define ELF32_ST_TYPE(val)      ((val) & 0xf)
#define ELF32_ST_INFO(bind, type)   (((bind) << 4) + ((type) & 0xf))

/* Both Elf32_Sym and Elf64_Sym use the same one-byte st_info field.  */
#define ELF64_ST_BIND(val)      ELF32_ST_BIND (val)
#define ELF64_ST_TYPE(val)      ELF32_ST_TYPE (val)
#define ELF64_ST_INFO(bind, type)   ELF32_ST_INFO ((bind), (type))
```

### .dynstr

This `.dynstr` section holds strings needed for dynamic linking, most commonly the strings that represent the names associated with symbol table entries.

```bash hl_lines="6"
$ readelf -p .dynstr a.out

String dump of section '.dynstr':
[     1]  __cxa_finalize
[    10]  __libc_start_main
[    22]  puts
[    27]  abort
[    2d]  libc.so.6
[    37]  GLIBC_2.17
[    42]  GLIBC_2.34
[    4d]  _ITM_deregisterTMCloneTable
[    69]  __gmon_start__
[    78]  _ITM_registerTMCloneTable
```

### hexdump .dynsym

As is shown in `readelf -d a.out`, `DT_SYMENT`=0x18, that means size of one symbol table entry (of `.dynsym`) is 24.

Hexdump contents of the `.dynsym`(DT_SYMTAB) section according to its prototyped TLV(*T*ype-*L*ength-*V*alue).

```bash hl_lines="14"
$ ds_offset=$(objdump -hw a.out | awk '/.dynsym/{print "0x"$6}')
$ ds_size=$(objdump -hw a.out | awk '/.dynsym/{print "0x"$3}')
$ hexdump -v -s $ds_offset -n $ds_size -e '"%016_ax " /4 "%08x\t" 2/1 "%02x\t\t\t" /2 "%04x\t" 2/8 "%016x\t" "\n"' a.out \
| awk 'BEGIN{print "offset\t\t\t\tname\tinfo\t\tother\tshndx\tvalue\t\t\t\tsize"} 1'
offset				name	info		other	shndx	value				size
00000000000002b8 00000000	00			00		0000	0000000000000000	0000000000000000
00000000000002d0 00000000	03			00		000b	00000000000005b8	0000000000000000
00000000000002e8 00000000	03			00		0016	0000000000011000	0000000000000000
0000000000000300 00000010	12			00		0000	0000000000000000	0000000000000000
0000000000000318 0000004d	20			00		0000	0000000000000000	0000000000000000
0000000000000330 00000001	22			00		0000	0000000000000000	0000000000000000
0000000000000348 00000069	20			00		0000	0000000000000000	0000000000000000
0000000000000360 00000027	12			00		0000	0000000000000000	0000000000000000
0000000000000378 00000022	12			00		0000	0000000000000000	0000000000000000
0000000000000390 00000078	20			00		0000	0000000000000000	0000000000000000
```

The macro `ELF32_ST_BIND`(:hi:4) and `ELF32_ST_TYPE`(:lo:4) defines how to extract information(ST_BIND, ST_TYPE) held in the `st_info` field of `Elf64_Sym`.

offset | name index | symbol name                 | info | type        | bind
-------|------------|-----------------------------|------|-------------|-----------
0x2b8  | 0x00000000 | N/A                         | 0x00 | STT_NOTYPE  | ST_LOCAL
0x2d0  | 0x00000000 | N/A                         | 0x03 | STT_SECTION | ST_LOCAL
0x2e8  | 0x00000000 | N/A                         | 0x03 | STT_SECTION | ST_LOCAL
0x300  | 0x00000010 | \_\_libc_start_main         | 0x12 | STT_FUNC    | STB_GLOBAL
0x318  | 0x0000004d | _ITM_deregisterTMCloneTable | 0x20 | STT_NOTYPE  | STB_WEAK
0x330  | 0x00000001 | \_\_cxa_finalize            | 0x22 | STT_FUNC    | STB_WEAK
0x348  | 0x00000069 | \_\_gmon_start\_\_          | 0x20 | STT_NOTYPE  | STB_WEAK
0x360  | 0x00000027 | abort                       | 0x12 | STT_FUNC    | STB_GLOBAL
0x378  | 0x00000022 | **puts**                    | 0x12 | STT_FUNC    | STB_GLOBAL
0x390  | 0x00000078 | \_ITM\_registerTMCloneTable | 0x20 | STT_NOTYPE  | STB_WEAK

### readelf/objdump

`nm -u|--undefined-only`: display only undefined symbols.
`nm -D|--dynamic`: display dynamic symbols instead of normal symbols.

```bash hl_lines="8"
# nm -u a.out
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
`objdump [-T|--dynamic-syms]`: display the contents of the dynamic symbol table.

=== "readelf --dyn-syms"

    ```bash hl_lines="13"
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

    ```bash hl_lines="13"
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

## relocation entries

```c title="Relocation table entry"
// /usr/include/elf.h

/* Relocation table entry with addend (in section of type SHT_RELA).  */

typedef struct
{
  Elf64_Addr    r_offset;       /* Address */
  Elf64_Xword   r_info;         /* Relocation type and symbol index */
  Elf64_Sxword  r_addend;       /* Addend */
} Elf64_Rela;

/* How to extract and insert information held in the r_info field.  */

#define ELF64_R_SYM(i)          ((i) >> 32)
#define ELF64_R_TYPE(i)         ((i) & 0xffffffff)
#define ELF64_R_INFO(sym,type)      ((((Elf64_Xword) (sym)) << 32) + (type))

/* LP64 AArch64 relocs.  */

#define R_AARCH64_GLOB_DAT     1025 /* 0x401: Create GOT entry.  */
#define R_AARCH64_JUMP_SLOT    1026 /* 0x402: Create PLT entry.  */
#define R_AARCH64_RELATIVE     1027 /* 0x403: Adjust by program base.  */

```

We know the following points from the previous analysis of the dynamic section.

1. `DT_PLTREL`=0x7=`DT_RELA`: Type of reloc in PLT.
2. `DT_RELA`=0x480: address of section `.rela.dyn`.
3. `DT_JMPREL`=0x540: address of section `.rela.plt`.

Use `readelf` or `objdump` to dump related sections.

```bash
readelf -R .got -R .rela.dyn -R .rela.plt -R .plt a.out
objdump -j .got -j .rela.dyn -j .rela.plt -j .plt -s a.out
```

### hexdump sections

As is shown in `readelf -d a.out`, `DT_RELAENT`=0x18, that means size of one RELA reloc is 24.

Hexdump contents of the `.rela.plt`(DT_RELA) section, grouped by unit of giant-word, 3 units per line.

> Pay attention to the offset, it points to a `.got` entry.

```bash
$ rd_offset=$(objdump -hw a.out | awk '/.rela.dyn/{print "0x"$6}')
$ rd_size=$(objdump -hw a.out | awk '/.rela.dyn/{print "0x"$3}')
$ hexdump -v -s $rd_offset -n $rd_size -e '"%016_ax  " 3/8 "%016x " "\n"' a.out \
| awk 'BEGIN{print "address\t\t\t\toffset\t\t\tinfo\t\t\taddend"} 1'
address				offset			info			addend
0000000000000480  0000000000010d90 0000000000000403 0000000000000750 # .init_array
0000000000000498  0000000000010d98 0000000000000403 0000000000000700 # .fini_array
00000000000004b0  0000000000010ff0 0000000000000403 0000000000000754 # GOT
00000000000004c8  0000000000011008 0000000000000403 0000000000011008 # .data[1]
00000000000004e0  0000000000010fd8 0000000400000401 0000000000000000 # GOT
00000000000004f8  0000000000010fe0 0000000500000401 0000000000000000 # GOT
0000000000000510  0000000000010fe8 0000000600000401 0000000000000000 # GOT
0000000000000528  0000000000010ff8 0000000900000401 0000000000000000 # GOT
```

00004c8 - 0000000000011008: the second giant word of `.dynsym` - `.data`(Offset=0x001000, Address=0x0011000 Size=0x000010), can be denoted as .data[1] under AArch64.

Adapt the hexdump format to make it more readable in the unit of the giant-word.

```bash
# readelf -x .data a.out
# objdump -j .data -s a.out
$ d_offset=$(objdump -hw a.out | awk '/\.data/ && !/\.nodata/ {print "0x"$6}')
$ d_size=$(objdump -hw a.out | awk '/\.data/ && !/\.nodata/ {print "0x"$3}')
$ hexdump -v -s $d_offset -n $d_size -e '"%07.7_ax  " 2/8 "%016x " "\n"' a.out
0001000  0000000000000000 0000000000011008
```

---

Hexdump contents of section `.rela.plt`(DT_JMPREL) grouped by unit of giant-word, 3 units per line.

> Pay attention to the offset, it points to a `.got` entry.

```bash
$ rp_offset=$(objdump -hw a.out | awk '/.rela.plt/{print "0x"$6}')
$ rp_size=$(objdump -hw a.out | awk '/.rela.plt/{print "0x"$3}')
$ hexdump -v -s $rp_offset -n $rp_size -e '"%016_ax  " 3/8 "%016x " "\n"' a.out \
| awk 'BEGIN{print "address\t\t\t\toffset\t\t\tinfo\t\t\taddend"} 1'
address				offset			info			addend
0000000000000540  0000000000010fa8 0000000300000402 0000000000000000
0000000000000558  0000000000010fb0 0000000500000402 0000000000000000
0000000000000570  0000000000010fb8 0000000600000402 0000000000000000
0000000000000588  0000000000010fc0 0000000700000402 0000000000000000
00000000000005a0  0000000000010fc8 0000000800000402 0000000000000000
```

The macros `ELF64_R_SYM` and `ELF64_R_TYPE` demonstrate how to extract information from the `r_info` field of `Elf64_Rela`.

Take the last entry as an example:

1. `ELF64_R_TYPE(0x0000000800000402)` = 0x00000402, aka `R_AARCH64_JUMP_SLOT`.
2. `ELF64_R_SYM(0x0000000800000402)` = 0x00000008, symbol index.

Cast a glance at section *dynamic symbol*, index 8 corresponds to `puts@GLIBC_2.17` in symbol table `.dynsym`.

Next, let's use professional ELF binutils like readelf/objdump/rabin2 to see what they come up with.

### readelf/objdump

`readelf [-r|--relocs]`: display the relocations.

```bash hl_lines="20"
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

!!! note "Dual Symbols"

    No. 5 `__cxa_finalize` and No. 6 `__gmon_start__` appear in both `.rela.dyn` and `.rela.plt` sections.

`objdump [-r|--reloc]`: display the relocation entries in the file.

```bash
$ objdump -r a.out

a.out:     file format elf64-littleaarch64

```

`objdump [-R|--dynamic-reloc]`: display the dynamic relocation entries in the file.

> Almost the same as `readelf -r a.out`, but the full TYPE name is visible.

```bash hl_lines="19"
$ objdump -R a.out

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

## global offset table

The global offset table (*`GOT`*) is created by the static linker in response to GOT generating relocations. See [AAELF64](https://github.com/ARM-software/abi-aa/blob/main/aaelf64/aaelf64.rst) Relocation operations for more information.

AArch64 splits the global offset table (GOT) into two sections:

- `.got.plt` for code addresses accessed only from the Procedure Linkage Table (PLT).
- `.got` all other addresses and offsets.

### hexdump .got

Hexdump contents of PROGBITS section `.got` grouped by giant-word array.

> 65536/0x10000 is the increment of vaddr over paddr for the LOAD1 segment where the `.got` section is located.

```bash hl_lines="14"
$ got_offset=$(objdump -hw a.out | awk '/.got/{print "0x"$6}')
$ got_size=$(objdump -hw a.out | awk '/.got/{print "0x"$3}')
$ hexdump -v -s $got_offset -n $got_size -e '"%_ad\t" /8 "%016x\t" "\n"' a.out \
| awk 'BEGIN{print "Offset\t\tAddress\t\t\t\tValue"} \
{printf("%08x\t", $1); printf("%016x\t", $1+65536); print $2}'
Offset		Address				Value
00000f90	0000000000010f90	0000000000000000
00000f98	0000000000010f98	0000000000000000
00000fa0	0000000000010fa0	0000000000000000
00000fa8	0000000000010fa8	00000000000005d0
00000fb0	0000000000010fb0	00000000000005d0
00000fb8	0000000000010fb8	00000000000005d0
00000fc0	0000000000010fc0	00000000000005d0
00000fc8	0000000000010fc8	00000000000005d0
00000fd0	0000000000010fd0	0000000000010da0
00000fd8	0000000000010fd8	0000000000000000
00000fe0	0000000000010fe0	0000000000000000
00000fe8	0000000000010fe8	0000000000000000
00000ff0	0000000000010ff0	0000000000000754
00000ff8	0000000000010ff8	0000000000000000
```

As we have discussed, the last entry in the `.rela.plt` (DT_JMPREL) section describes the `R_AARCH64_JUMP_SLOT` / GOT entry with address `0000000000010fc8`(offset 0xfc8 within LOAD1) and symbol index 8, corresponding to `puts@GLIBC_2.17` in symbol table `.dynsym`.

The `puts@GLIBC_2.17` is currently labelled as `UND`EFINED, the corresponding GOT entry is filled with `00000000000005d0`, which represents the `.plt` section in the LOAD0 segment.

When the required(DT_NEEDED) *libc.so* is loaded, the value would be resolved to be the actual address of symbol `puts@GLIBC_2.17` during process initialization.

### \_GLOBAL_OFFSET_TABLE\_

For AArch64 the linker defined `_GLOBAL_OFFSET_TABLE_` symbol should be the address of the first global offset table entry in the `.got` section.

```bash
$ readelf -s a.out

    Symbol table '.symtab' contains 88 entries:
    Num:    Value          Size Type    Bind   Vis      Ndx Name

    63: 0000000000010fd0     0  OBJECT  LOCAL  DEFAULT  ABS _GLOBAL_OFFSET_TABLE_

$ objdump -t a.out

    0000000000010fd0 l     O *ABS*	0000000000000000              _GLOBAL_OFFSET_TABLE_

$ nm a.out

    0000000000010fd0 a _GLOBAL_OFFSET_TABLE_
```

The value of `_GLOBAL_OFFSET_TABLE_`(0x0000000000010fd0) is 0x0000000000010da0, it's the address of the `.dynamic` section.

## puts@plt

The *`GOT`*(Global Offset Table) is something like a socket, it connects the internal host and the external required.

Similar to how the global offset table redirects position-independent address calculations to absolute locations, the procedure linkage table(*`PLT`*) redirects position-independent function calls to absolute locations.

The dynamic section `DT_PLTREL`(0000000000000014)=0x7 shows its type of reloc in PLT is `DT_RELA`.

Relocation section `.rela.plt` defines five `R_AARCH64_JUMP_SLOT`s pointing to GOT entries with offest. The indexes of the dynamic symbols are 3,5,6,7,8.

`rabin2 -i` puts things on the stage, e.g. No.8 0x00000630 points to the PLT stub routine <puts@plt\>.

```bash hl_lines="10"
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

<puts@plt\> uses *ADRP*/*LDR* to load the reloc address stored in `R_AARCH64_JUMP_SLOT` / GOT entry for `puts@GLIBC_2.17`, then calls *BR* to jump to the target.

`rabin2 -R` lists the RELA relocations whose `vaddr` points to the GOT entry that stores the adjusted address. The highlighted line's vaddr=0x00010fc8 is the GOT slot address for `reloc.puts`.

```bash hl_lines="13"
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

The `PLT` is acting as a go-between, and it's time to lift the veil.

### disassemble

Statically disassemble the `.plt` section using `objdump -d` command.

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

$ rax2 4040
0xfc8
```

If you only want to disassemble the `puts@plt` symbol, not the whole section, you could specify the symbol or an address range for objdump.

```bash
# puts_plt=$(rabin2 -i a.out | awk '/puts/ {print $2}')
# objdump -d --start-address=$puts_plt --stop-address=$((puts_plt+16)) a.out
$ objdump --disassemble=puts@plt a.out
```

### resolution

As we can see, 0x10000+0xfc8 is the offset of `.rela.plt` relocation entry. The output of `rabin2 -R a.out` maybe more clear: the vaddr=0x00010fc8 is relative to virtual baddr, while the paddr=0x00000fc8 is relative to memory segment.

Line 40 `adrp x16, 10000` is used to form PC-relative address to 4KB page. `IMM = 0x10000` is the PC-relative literal that encoded in the [ADRP instruction](../arm/arm-adr-demo.md).

Lines 41\~42 are the equivalent expansion of the pre-indexing addressing instruction `ldr x17, [x16, #0xfc8]!`. Reg `x17` will load the value stored in GOT entry 0x10fc8 (PC relative). It is currently 0x5d0 and will be adjusted during dynamic linking. This is usually called "lazy symbol binding/loading".

In the following articles, we'll explore how PLT/RELA/GOT work together to resolve lazy symbol binding/loading in dynamic linking.
