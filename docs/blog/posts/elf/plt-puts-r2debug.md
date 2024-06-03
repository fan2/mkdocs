---
title: puts@plt - r2 debug
authors:
    - xman
date:
    created: 2023-06-30T10:00:00
categories:
    - elf
tags:
    - PLT
    - GOT
comments: true
---

[Previously](./plt-puts-pwndbg.md), we've dynamically analysed how shared dynamic symbols such as `puts` are resolved and relocated at runtime using gdb-pwndbg.

In this article, we'll do the same work, but change our dynamic analysis tool to the popular open-source SRE toolkit r2(aka [radare2](../toolchain/sre-radare2.md)).

<!-- more -->

Run the DYN ELF `a.out` with the `-A` option using r2.

> `-A` will run `aaa` command BTS to analyze all referenced code.

```bash
$ r2 -dA a.out
```

## entry point vaddr

Check base address(`baddr`) and `paddr`/`vaddr` of entry point.

```bash
[0xffff98492c40]> i ~baddr
baddr    0xaaaadc760000
[0xffff98492c40]> rabin2 -eq a.out
0x00000640
[0xffff98492c40]> ieq
0xaaaadc760640
```

List entries+constructors:

```bash
[0xffff98492c40]> ieee
[Constructors]
vaddr=0xaaaadc760750 paddr=0x00000750 hvaddr=0xaaaadc770d90 hpaddr=0x00000d90 type=init
vaddr=0xaaaadc760700 paddr=0x00000700 hvaddr=0xaaaadc770d98 hpaddr=0x00000d98 type=fini

2 entrypoints
[Entrypoints]
vaddr=0xaaaadc760640 paddr=0x00000640 haddr=0x00000018 hvaddr=0xaaaadc760018 type=program

1 entrypoints
```

## loaded modules

First, list modules (libraries, binaries loaded in memory) to see where we are and what's been loaded.

> As the debugging process breaks at a very early stage, it still halts in the interpreter's module.

```bash
[0xffff98492c40]> dmm.
INFO: modules.get
0xffff9847b000 0xffff984a6000  /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
```

List modules of target process.

> There are only two modules loaded at the moment, the interpreter and our demo.

```bash
[0xffff98492c40]> dmm
INFO: modules.get
0xaaaadc760000 0xaaaadc761000  /home/pifan/Projects/cpp/a.out
0xffff9847b000 0xffff984a6000  /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
```

## memory maps

Show map name of current address.

> We're staying in the LOAD0 segment of the interpreter `ld-linux-aarch64.so`.

```bash
[0xffff98492c40]> dm.
0x0000ffff9847b000 - 0x0000ffff984a6000 * usr   172K s r-x /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.r_x
```

List memory maps of current/target process.

> `r-x` marks LOAD0 segment; `rw-` designates LOAD1 segment.

```bash
[0xffff98492c40]> dm
0x0000aaaadc760000 - 0x0000aaaadc761000 - usr     4K s r-x /home/pifan/Projects/cpp/a.out /home/pifan/Projects/cpp/a.out ; map._home_pifan_Projects_cpp_a.out.r_x
0x0000aaaadc770000 - 0x0000aaaadc772000 - usr     8K s rw- /home/pifan/Projects/cpp/a.out /home/pifan/Projects/cpp/a.out ; map._home_pifan_Projects_cpp_a.out.rw_
0x0000ffff9847b000 - 0x0000ffff984a6000 * usr   172K s r-x /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.r_x
0x0000ffff984b2000 - 0x0000ffff984b4000 - usr     8K s r-- [vvar] [vvar] ; map._vvar_.r__
0x0000ffff984b4000 - 0x0000ffff984b5000 - usr     4K s r-x [vdso] [vdso] ; map._vdso_.r_x
0x0000ffff984b5000 - 0x0000ffff984b9000 - usr    16K s rw- /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.rw_
0x0000ffffc7fcd000 - 0x0000ffffc7fee000 - usr   132K s rw- [stack] [stack] ; map._stack_.rw_
```

## sections2segments

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

From the above output of the section to segment mapping we can see that the sections `.rela.dyn`, `.rela.plt` and `.plt` along with the `.text` have been classified into the first loadable text segment *LOAD0*.

Meanwhile, the `.dynamic` and `.got` sections along with the `.data` seciton have been categorized into the second loadable data segment *LOAD1*.

`rabin2 -S` / `iS`: sections

```bash
[0xffff98492c40]> iS
[Sections]

nth paddr        size vaddr           vsize perm type        name
―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x00000000    0x0 0x00000000        0x0 ---- NULL
1   0x00000238   0x1b 0xaaaadc760238   0x1b -r-- PROGBITS    .interp
2   0x00000254   0x24 0xaaaadc760254   0x24 -r-- NOTE        .note.gnu.build-id
3   0x00000278   0x20 0xaaaadc760278   0x20 -r-- NOTE        .note.ABI-tag
4   0x00000298   0x1c 0xaaaadc760298   0x1c -r-- GNU_HASH    .gnu.hash
5   0x000002b8   0xf0 0xaaaadc7602b8   0xf0 -r-- DYNSYM      .dynsym
6   0x000003a8   0x92 0xaaaadc7603a8   0x92 -r-- STRTAB      .dynstr
7   0x0000043a   0x14 0xaaaadc76043a   0x14 -r-- GNU_VERSYM  .gnu.version
8   0x00000450   0x30 0xaaaadc760450   0x30 -r-- GNU_VERNEED .gnu.version_r
9   0x00000480   0xc0 0xaaaadc760480   0xc0 -r-- RELA        .rela.dyn
10  0x00000540   0x78 0xaaaadc760540   0x78 -r-- RELA        .rela.plt
11  0x000005b8   0x18 0xaaaadc7605b8   0x18 -r-x PROGBITS    .init
12  0x000005d0   0x70 0xaaaadc7605d0   0x70 -r-x PROGBITS    .plt
13  0x00000640  0x13c 0xaaaadc760640  0x13c -r-x PROGBITS    .text
14  0x0000077c   0x14 0xaaaadc76077c   0x14 -r-x PROGBITS    .fini
15  0x00000790   0x16 0xaaaadc760790   0x16 -r-- PROGBITS    .rodata
16  0x000007a8   0x3c 0xaaaadc7607a8   0x3c -r-- PROGBITS    .eh_frame_hdr
17  0x000007e8   0xac 0xaaaadc7607e8   0xac -r-- PROGBITS    .eh_frame
18  0x00000d90    0x8 0xaaaadc770d90    0x8 -rw- INIT_ARRAY  .init_array
19  0x00000d98    0x8 0xaaaadc770d98    0x8 -rw- FINI_ARRAY  .fini_array
20  0x00000da0  0x1f0 0xaaaadc770da0  0x1f0 -rw- DYNAMIC     .dynamic
21  0x00000f90   0x70 0xaaaadc770f90   0x70 -rw- PROGBITS    .got
22  0x00001000   0x10 0xaaaadc771000   0x10 -rw- PROGBITS    .data
23  0x00001010    0x0 0xaaaadc771010    0x8 -rw- NOBITS      .bss
24  0x00001010   0x2b 0x00000000       0x2b ---- PROGBITS    .comment
25  0x00001040  0x840 0x00000000      0x840 ---- SYMTAB      .symtab
26  0x00001880  0x22c 0x00000000      0x22c ---- STRTAB      .strtab
27  0x00001aac   0xfa 0x00000000       0xfa ---- STRTAB      .shstrtab
```

`rabin2 -SS` / `iSS`: segments

```bash
[0xffff98492c40]> iSS
[Segments]

nth paddr        size vaddr           vsize perm type name
――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x00000040  0x1f8 0xaaaadc760040  0x1f8 -r-- MAP  PHDR
1   0x00000238   0x1b 0xaaaadc760238   0x1b -r-- MAP  INTERP
2   0x00000000  0x894 0xaaaadc760000  0x894 -r-x MAP  LOAD0
3   0x00000d90  0x280 0xaaaadc770d90  0x288 -rw- MAP  LOAD1
4   0x00000da0  0x1f0 0xaaaadc770da0  0x1f0 -rw- MAP  DYNAMIC
5   0x00000254   0x44 0xaaaadc760254   0x44 -r-- MAP  NOTE
6   0x000007a8   0x3c 0xaaaadc7607a8   0x3c -r-- MAP  GNU_EH_FRAME
7   0x00000000    0x0 0xaaaadc760000    0x0 -rw- MAP  GNU_STACK
8   0x00000d90  0x270 0xaaaadc770d90  0x270 -r-- MAP  GNU_RELRO
9   0x00000000   0x40 0xaaaadc760000   0x40 -rw- MAP  ehdr

```

According to the mapping relationship, LOAD0's first section is `.interp`, of whose vaddr is 0xaaaadc760238.
As `readelf -lW a.out` indicated, it should be aligned at 0x10000(64K), so the segment vaddr is 0xaaaadc760000.

> Why is the vaddr of LOAD1 segment is 0xaaaadc770d90, not 0xaaaadc770000?

## imports/relocations

> `puts@plt` is labelled as `sym.imp.puts`/`rsym.puts` by r2 after loading.

Type `ii` to list the symbols imported from other libraries.

> The vaddr of relocated symbol `rsym.puts` in PLT is 0xaaaadc760630.

```bash
[0xffff98492c40]> ii
[Imports]
nth vaddr          bind   type   lib name
―――――――――――――――――――――――――――――――――――――――――
3   0xaaaadc7605f0 GLOBAL FUNC       __libc_start_main
4   ----------     WEAK   NOTYPE     _ITM_deregisterTMCloneTable
5   0xaaaadc760600 WEAK   FUNC       __cxa_finalize
6   0xaaaadc760610 WEAK   NOTYPE     __gmon_start__
7   0xaaaadc760620 GLOBAL FUNC       abort
8   0xaaaadc760630 GLOBAL FUNC       puts
9   ----------     WEAK   NOTYPE     _ITM_registerTMCloneTable

[0xffff98492c40]> # ?v sym.imp.puts
[0xffff98492c40]> ?v rsym.puts
0xaaaadc760630
```

Type `ir` to list the relocations.

> The offset of the relocated symbol in GOT, `reloc.puts`, is 0x00000fc8.

```bash
[0xffff98492c40]> ir
WARN: Relocs has not been applied. Please use `-e bin.relocs.apply=true` or `-e bin.cache=true` next time
[Relocations]

vaddr          paddr      type   ntype name
―――――――――――――――――――――――――――――――――――――――――――
0xaaaadc770d90 0x00000d90 ADD_64 1027   0x00000750
0xaaaadc770d98 0x00000d98 ADD_64 1027   0x00000700
0xaaaadc770fa8 0x00000fa8 SET_64 1026  __libc_start_main
0xaaaadc770fb0 0x00000fb0 SET_64 1026  __cxa_finalize
0xaaaadc770fb8 0x00000fb8 SET_64 1026  __gmon_start__
0xaaaadc770fc0 0x00000fc0 SET_64 1026  abort
0xaaaadc770fc8 0x00000fc8 SET_64 1026  puts
0xaaaadc770fd8 0x00000fd8 SET_64 1025  _ITM_deregisterTMCloneTable
0xaaaadc770fe0 0x00000fe0 SET_64 1025  __cxa_finalize
0xaaaadc770fe8 0x00000fe8 SET_64 1025  __gmon_start__
0xaaaadc770ff0 0x00000ff0 ADD_64 1027   0x00000754
0xaaaadc770ff8 0x00000ff8 SET_64 1025  _ITM_registerTMCloneTable
0xaaaadc771008 0x00001008 ADD_64 1027   0x00011008


13 relocations
```

Let's try to disassemble the relocation of `__libc_start_main`.

> Refer to the output of `ir` to see the vaddr.

```bash
[0xffff98492c40]> pd @0xaaaadc770fa8
            ;-- reloc.__libc_start_main:
            0xaaaadc770fa8      d0050000       invalid
            0xaaaadc770fac      00000000       invalid
            0xaaaadc770fb0      d0050000       invalid
            0xaaaadc770fb4      00000000       invalid
            0xaaaadc770fb8      d0050000       invalid
            0xaaaadc770fbc      00000000       invalid
            ;-- reloc.abort:
            0xaaaadc770fc0      d0050000       invalid
            0xaaaadc770fc4      00000000       invalid
            ;-- reloc.puts:
            0xaaaadc770fc8      d0050000       invalid
            0xaaaadc770fcc      00000000       invalid
            ;-- _GLOBAL_OFFSET_TABLE_:
            0xaaaadc770fd0      a00d0100       invalid
            0xaaaadc770fd4      00000000       invalid
            ;-- reloc._ITM_deregisterTMCloneTable:
            0xaaaadc770fd8      00000000       invalid
            0xaaaadc770fdc      00000000       invalid
            ;-- reloc.__cxa_finalize:
            0xaaaadc770fe0      00000000       invalid
            0xaaaadc770fe4      00000000       invalid
            ;-- reloc.__gmon_start__:
            0xaaaadc770fe8      00000000       invalid
            0xaaaadc770fec      00000000       invalid
            0xaaaadc770ff0      54070000       invalid
            0xaaaadc770ff4      00000000       invalid
            ;-- reloc._ITM_registerTMCloneTable:
            0xaaaadc770ff8      00000000       invalid
            0xaaaadc770ffc      00000000       invalid
            ;-- section..data:
            ;-- data_start:
            ;-- __data_start:
            ; XREFS: DATA 0xaaaadc760690  DATA 0xaaaadc760698  DATA 0xaaaadc7606c0  DATA 0xaaaadc7606c8  DATA 0xaaaadc76070c
            ; XREFS: DATA 0xaaaadc760724
            0xaaaadc771000      00000000       invalid                 ; [22] -rw- section size 16 named .data
            0xaaaadc771004      00000000       invalid
            ;-- __dso_handle:
            0xaaaadc771008      08100100       invalid
            0xaaaadc77100c      00000000       invalid
            ;-- section..bss:
            0xaaaadc771010      00000000       invalid                 ; [23] -rw- section size 8 named .bss
```

Get the value(address) of label `reloc.puts` by evaluation:

```bash
[0xffff98492c40]> ?v reloc.puts
0xaaaadc770fc8
```

## entry0 -> main

```bash
[0xffffbb1c0c40]> rabin2 -l a.out
[Linked libraries]
libc.so.6

1 library
```

### dcu entry0

Continue until `entry0`(aka `_start`), refer to `entry point vaddr` and check:

```bash
[0xffff98492c40]> dcu entry0
INFO: Continue until 0xaaaadc760640 using 4 bpsize
INFO: hit breakpoint at: 0xaaaadc760640
```

Type `pdf` to disassemble function at current pc, that is `entry0`:

```bash
[0xaaaadc760640]> pdf
            ;-- section..text:
            ;-- _start:
            ;-- x16:
            ;-- x21:
            ;-- pc:
            ;-- d16:
            ;-- d21:
┌ 48: entry0 (int64_t arg1, int64_t arg_0h, int64_t arg_8h); // noreturn
│           ; arg int64_t arg1 @ x0
│           ; arg int64_t arg_0h @ sp+0x0
│           ; arg int64_t arg_8h @ sp+0x8
│           0xaaaadc760640      1f2003d5       nop                     ; [13] -r-x section size 316 named .text
│           0xaaaadc760644      1d0080d2       mov x29, 0
│           0xaaaadc760648      1e0080d2       mov x30, 0
│           0xaaaadc76064c      e50300aa       mov x5, x0              ; arg1
│           0xaaaadc760650      e10340f9       ldr x1, [sp]
│           0xaaaadc760654      e2230091       add x2, arg_8h
│           0xaaaadc760658      e6030091       mov x6, sp
│           0xaaaadc76065c      80000090       adrp x0, map._home_pifan_Projects_cpp_a.out.rw_ ; 0xaaaadc770000
│           0xaaaadc760660      00f847f9       ldr x0, [x0, 0xff0]
│           0xaaaadc760664      030080d2       mov x3, 0
│           0xaaaadc760668      040080d2       mov x4, 0
└           0xaaaadc76066c      e1ffff97       bl sym.imp.__libc_start_main ; int __libc_start_main(func main, int argc, char **ubp_av, func init, func fini, func rtld_fini, void *stack_end)
```

### libc vmmap

Type `dmm` to check the latest modules.

1. We're now running in the text segment of a.out.
2. Dynamic library `libc.so` have been loaded at the moment.

```bash
[0xaaaadc760640]> dmm.
INFO: modules.get
0xaaaadc760000 0xaaaadc761000  /home/pifan/Projects/cpp/a.out
[0xaaaadc760640]> dmm
INFO: modules.get
0xaaaadc760000 0xaaaadc761000  /home/pifan/Projects/cpp/a.out
0xffff982c0000 0xffff98448000  /usr/lib/aarch64-linux-gnu/libc.so.6
0xffff9847b000 0xffff984a6000  /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
```

Type `dm` to check the latest memory map:

> `libc.so` is loaded into memory with four segments as highlighted.

```bash linenums="1" hl_lines="7-10"
[0xaaaadc760640]> dm.
0x0000aaaadc760000 - 0x0000aaaadc761000 * usr     4K s r-x /home/pifan/Projects/cpp/a.out /home/pifan/Projects/cpp/a.out ; map._home_pifan_Projects_cpp_a.out.r_x
[0xaaaadc760640]> dm
0x0000aaaadc760000 - 0x0000aaaadc761000 * usr     4K s r-x /home/pifan/Projects/cpp/a.out /home/pifan/Projects/cpp/a.out ; map._home_pifan_Projects_cpp_a.out.r_x
0x0000aaaadc770000 - 0x0000aaaadc771000 - usr     4K s r-- /home/pifan/Projects/cpp/a.out /home/pifan/Projects/cpp/a.out ; map._home_pifan_Projects_cpp_a.out.rw_
0x0000aaaadc771000 - 0x0000aaaadc772000 - usr     4K s rw- /home/pifan/Projects/cpp/a.out /home/pifan/Projects/cpp/a.out ; loc.__data_start
0x0000ffff982c0000 - 0x0000ffff98448000 - usr   1.5M s r-x /usr/lib/aarch64-linux-gnu/libc.so.6 /usr/lib/aarch64-linux-gnu/libc.so.6
0x0000ffff98448000 - 0x0000ffff98457000 - usr    60K s --- /usr/lib/aarch64-linux-gnu/libc.so.6 /usr/lib/aarch64-linux-gnu/libc.so.6
0x0000ffff98457000 - 0x0000ffff9845b000 - usr    16K s r-- /usr/lib/aarch64-linux-gnu/libc.so.6 /usr/lib/aarch64-linux-gnu/libc.so.6
0x0000ffff9845b000 - 0x0000ffff9845d000 - usr     8K s rw- /usr/lib/aarch64-linux-gnu/libc.so.6 /usr/lib/aarch64-linux-gnu/libc.so.6
0x0000ffff9845d000 - 0x0000ffff98469000 - usr    48K s rw- unk0 unk0
0x0000ffff9847b000 - 0x0000ffff984a6000 - usr   172K s r-x /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.r_x
0x0000ffff984ae000 - 0x0000ffff984b2000 - usr    16K s rw- unk1 unk1
0x0000ffff984b2000 - 0x0000ffff984b4000 - usr     8K s r-- [vvar] [vvar] ; map._vvar_.r__
0x0000ffff984b4000 - 0x0000ffff984b5000 - usr     4K s r-x [vdso] [vdso] ; map._vdso_.r_x
0x0000ffff984b5000 - 0x0000ffff984b7000 - usr     8K s r-- /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.rw_
0x0000ffff984b7000 - 0x0000ffff984b9000 - usr     8K s rw- /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
0x0000ffffc7fcd000 - 0x0000ffffc7fee000 - usr   132K s rw- [stack] [stack] ; map._stack_.rw_
```

### dcu main

Set a breakpoint at `main` and continue.

```bash
[0xaaaadc760640]> db main; dc
[+] SIGNAL 28 errno=0 addr=0x00000000 code=128 si_pid=0 ret=0
INFO: hit breakpoint at: 0xaaaadc760754
[+] signal 28 aka SIGWINCH received 0 (Window Changed Size)
[0xaaaadc760754]> pdf
            ;-- x3:
            ;-- x23:
            ;-- pc:
            ;-- d3:
            ;-- d23:
┌ 40: int main (int argc, char **argv);
│           ; arg int argc @ x0
│           ; arg char **argv @ x1
│           0xaaaadc760754 b    fd7bbea9       stp x29, x30, [sp, -0x20]!
│           0xaaaadc760758      fd030091       mov x29, sp
│           0xaaaadc76075c      e01f00b9       str w0, [sp, 0x1c]      ; argc
│           0xaaaadc760760      e10b00f9       str x1, [sp, 0x10]      ; argv
│           0xaaaadc760764      00000090       adrp x0, segment.LOAD0  ; map._home_pifan_Projects_cpp_a.out.r_x
│                                                                      ; 0xaaaadc760000
│           0xaaaadc760768      00601e91       add x0, x0, 0x798
│           0xaaaadc76076c      b1ffff97       bl sym.imp.puts         ; int puts(const char *s)
│           0xaaaadc760770      00008052       mov w0, 0
│           0xaaaadc760774      fd7bc2a8       ldp x29, x30, [sp], 0x20
└           0xaaaadc760778      c0035fd6       ret
```

## rsym.puts

[Previously](./plt-puts-analysis.md), we've statically disassembled the `.plt` section using `objdump` command.

```bash
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

[...snip...]

0000000000000630 <puts@plt>:
 630:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf770>
 634:	f947e611 	ldr	x17, [x16, #4040]
 638:	913f2210 	add	x16, x16, #0xfc8
 63c:	d61f0220 	br	x17
```

As we can see, 0x10000+0xfc8 is the offset of `puts` in `.rela.plt` entries of `readelf -r a.out` and relocation records of `objdump -R a.out`.

The output of `rabin2 -R a.out` maybe more clear: the vaddr=0x00010fc8 is relative to virtual baddr, while the paddr=0x00000fc8 is relative to physical segment.

### disassemble

Now, set a breakpoint at `rsym.puts` and continue. Then type `pdf` to see its dissembly.

```bash
[0xaaaadc760754]> db rsym.puts; dc
INFO: hit breakpoint at: 0xaaaadc760758
INFO: hit breakpoint at: 0xaaaadc760630
[0xaaaadc760630]> pdf
            ;-- rsym.puts:
            ;-- pc:
            ; CALL XREF from main @ 0xaaaadc76076c(x)
┌ 16: int sym.imp.puts (const char *s);
│           0xaaaadc760630 b    90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_ ; 0xaaaadc770000
│           0xaaaadc760634      11e647f9       ldr x17, [x16, 0xfc8]
│           0xaaaadc760638      10223f91       add x16, x16, 0xfc8
└           0xaaaadc76063c      20021fd6       br x17
```

View the instructions against puts@plt, it's easy to find that `10000 <__FRAME_END__+0xf770>` is replaced by `map._home_pifan_Projects_cpp_a.out.rw_`.

Refer to the memory map dumped by `dm`, `map._home_pifan_Projects_cpp_a.out.rw_` is the map name of `a.out`'s text segment LOAD0 which starts at 0x0000aaaadc770000.

`ADRP` will load its 4K page-boundary aligned address(`:pg_hi21:`) to x16. The result is the same as the start of the text segment LOAD0, which is already aligned at 0x10000(64K)(refer to the program headers dumped by `readelf -lW a.out`).

After `ldr x17, [x16, 0xfc8]!`, x17 will load the *address* stored in 0x0000aaaadc770fc8.

1. segment_addr+paddr(offset) = 0x0000aaaadc770000+0xfc8 = 0x0000aaaadc770fc8
2. baddr+vaddr = 0xaaaadc760000 + 0x00010fc8 = 0x0000aaaadc770fc8

Let's examine the memory:

```bash
[0xaaaadc760630]> pxq 8 @ 0xaaaadc770000+0xfc8
0xaaaadc770fc8  0x0000ffff9832ae70                       p.2.....
```

The address `0x0000ffff9832ae70` resides in module `libc.so`. To be precise, it's located between the address range, 0x0000ffff982c0000 - 0x0000ffff98448000, of which is mapped from the text segment LOAD0.

The following instruction `br x17` just jump to `0x0000ffff9832ae70`, which should be the real address(function pointer) of `puts` in libc.so.

### paddr -> vaddr

Let's look up symbol `puts` in libc.so.6, the weak symbol `puts` will be overriden by the global symbol `_IO_puts`.

```bash
[0xaaaae5360630]> !nm -gD /usr/lib/aarch64-linux-gnu/libc.so.6 | grep puts

000000000006ae70 T _IO_puts@@GLIBC_2.17
000000000006ae70 W puts@@GLIBC_2.17

[0xaaaae5360630]> !readelf -s /usr/lib/aarch64-linux-gnu/libc.so.6 | grep puts

   Num:    Value          Size Type    Bind   Vis      Ndx Name

  1400: 000000000006ae70   492 FUNC    WEAK   DEFAULT   12 puts@@GLIBC_2.17
  1409: 000000000006ae70   492 FUNC    GLOBAL DEFAULT   12 _IO_puts@@GLIBC_2.17

[0xaaaae5360630]> !objdump -t /usr/lib/aarch64-linux-gnu/libc.so.6 | grep puts

000000000006ae70  w    F .text	00000000000001ec puts
000000000006ae70 g     F .text	00000000000001ec _IO_puts
```

The value of the symbol `puts` is `000000000006ae70`, which is the static absolute paddr and will be adjusted to vaddr when loaded into memory.

Type `dmi` to list symbols of `libc.so` and grep symbol `puts`:

```bash
[0xaaaae5360630]> dmi libc.so ~puts

[Symbols]
nth paddr      vaddr          bind   type  size  lib name
――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

1400 0x0006ae70 0xffff9832ae70 WEAK   FUNC 492       puts
1409 0x0006ae70 0xffff9832ae70 GLOBAL FUNC 492       _IO_puts
```

Look back in the *libc vmmap* section, the vaddr of puts/_IO_puts 0xffff9832ae70 is between 0x0000ffff982c0000 - 0x0000ffff98448000, that is the area of the LOAD0 text segment.

Well, keep in mind `vaddr = baddr + paddr`.

According to the latest `dm` output(linkmap), the *Load Bias* of libc.so is 0xffff982c0000. It's also the start address of text segment LOAD0 according to the latest `dmm` output(vmmap), 0x0000ffff982c0000.

Add the paddr/offset to the baddr/bias to check the correctness of the formula.

```bash
[0xaaaadc760630]> ?v 0xffff982c0000+0x6ae70
0xffff9832ae70
```

Nothing is out of the ordinary. So far, everything is working as expected.