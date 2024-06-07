---
title: reloc puts@plt via GOT - r2 debug
authors:
    - xman
date:
    created: 2023-06-30T10:00:00
categories:
    - elf
tags:
    - .rela.plt
    - .got
    - .plt
    - reloc.puts
comments: true
---

[Previously](./plt-puts-pwndbg.md), we've dynamically analysed how shared dynamic symbols such as `puts` are resolved and relocated at runtime using gdb-pwndbg.

In this article, we'll do the same work, but change our dynamic analysis tool to the popular open-source SRE toolkit r2(aka [radare2](../toolchain/radare2-basics.md)).

It is also a thorough and comprehensive debugging exercise, demonstrating the power and versatility of the `r2` toolset.

<!-- more -->

Run the DYN ELF `a.out` with the `-d` and `-A` options using r2.

```bash
$ r2 -dA a.out
```

1. `-d`: debug the executable, behaved as `gdb -> starti`.
2. `-A` will run `aaa` command to analyze all referenced code.

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

[0xffff98492c40]> iM
[Main]
vaddr=0xaaaadc760754 paddr=0x00000754
```

[radare2 - What does paddr, baddr, laddr, haddr, and hvaddr refer to?](https://reverseengineering.stackexchange.com/questions/19782/what-does-paddr-baddr-laddr-haddr-and-hvaddr-refer-to)

- `vaddr` - Virtual Address
- `paddr` - Physical Address
- `laddr` - Load Address
- `baddr` - Base Address
- `haddr` - e_entry/AddressOfEntryPoint in binary header
- `hvaddr` - Header Physical Address
- `hpaddr` - e_entry/AddressOfEntryPoint offset in binary header

[assembly - VA (Virtual Address) & RVA (Relative Virtual Address)](https://stackoverflow.com/questions/2170843/va-virtual-address-rva-relative-virtual-address)

Usually the RVA in image files is relative to process base address when being loaded into memory, but some RVA may be relative to the "section" starting address in image or object files (you have to check the PE format spec for detail). No matter which, RVA is relative to "some" base VA.

1. Physical Memory Address is what CPU sees
2. Virtual Addreess (VA) is relative to Physical Address, per process (managed by OS)
3. RVA is relative to VA (file base or section base), per file (managed by linker and loader)

Most RVAs are given relative to the beginning of the file, but occasionally (especially when looking at object files instead of executables) you'll see an RVA based on the section.

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

At the moment, the dependent *libc.so* is not loaded.

```bash
[0xffff98492c40]> il
[Linked libraries]
libc.so.6

1 library
```

## memory maps

Show map name of current address.

> We're staying in the *LOAD0* segment of the interpreter `ld-linux-aarch64.so`.

```bash
[0xffff98492c40]> dm.
0x0000ffff9847b000 - 0x0000ffff984a6000 * usr   172K s r-x /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.r_x
```

List memory maps of current/target process.

1. Two loadable segments exist per so, *LOAD0* and *LOAD1*.
2. `r-x` marks *LOAD0* segment; `rw-` designates *LOAD1* segment.

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

Use `readelf` or `objdump` to display the sections' header.

- `readelf [-S|--section-headers]`: display the sections' header
- `objdump [-h|--[section-]headers]`: display the contents of the section headers

Use `readelf -lW` to display the program headers.

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

According to the mapping relationship, *LOAD0*'s first section is `.interp`, of whose vaddr is 0xaaaadc760238.
As `readelf -lW a.out` indicated, it should be aligned at 0x10000(64K), so the segment vaddr is 0xaaaadc760000.

!!! question "vaddr of LOAD1"

    Why is the vaddr of the *LOAD1* segment shown as 0xaaaadc770d90 and not 0xaaaadc770000?
    It seems to be the vaddr of the first section `.init_array`.

## imports/relocations

`nm -u|-D`: display only undefined/dynamic symbols.

```bash hl_lines="8"
# nm -D a.out
$ nm -u a.out
                 U abort@GLIBC_2.17
                 w __cxa_finalize@GLIBC_2.17
                 w __gmon_start__
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
                 U __libc_start_main@GLIBC_2.34
                 U puts@GLIBC_2.17
```

The PLT stub `puts@plt` for `puts@GLIBC_2.17` is labelled as `sym.imp.puts`/`rsym.puts` by r2 after loading.

Type `ii` to list the symbols imported from other libraries.

> The vaddr of relocated symbol `rsym.puts` in PLT can be calculated as follows.
> VA = baddr+offset/RVA = 0xaaaadc760000 + 0x00000630 = 0xaaaadc760630.

```bash hl_lines="10"
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

> The vaddr offset of the relocated symbol(`reloc.puts`) in GOT is 0x00010fc8.
> VA = baddr+offset/RVA = 0xaaaadc760000 + 0x00010fc8 = 0xaaaadc770fc8.

```bash hl_lines="13"
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

Try to show context disassembly of 15 instructions around `puts`.

> The GOT entry for `puts@plt` is labelled as `reloc.puts` by r2, equivalent to `puts@got.plt` in pwndbg.

```bash hl_lines="20"
[0xffff98492c40]> pd-- 15 @0xaaaadc770fc8
            0xaaaadc770f8c      00000000       invalid
            ;-- section..got:
            0xaaaadc770f90      00000000       invalid                 ; [21] -rw- section size 112 named .got
            0xaaaadc770f94      00000000       invalid
            0xaaaadc770f98      00000000       invalid
            0xaaaadc770f9c      00000000       invalid
            0xaaaadc770fa0      00000000       invalid
            0xaaaadc770fa4      00000000       invalid
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
            0xaaaae0071000      00000000       invalid                 ; [22] -rw- section size 16 named .data
```

Get the value(address) of label `reloc.puts` by evaluation:

```bash
[0xffff98492c40]> ?v reloc.puts
0xaaaadc770fc8
```

Use the `x` command to see what is stored at 0xaaaadc770fc8:

```bash
[0xffff98492c40]> pxq $w @ 0xaaaadc770fc8
0xaaaadc770fc8  0x00000000000005d0
```

According to the hexdump content of the `.got` section, it's originally filled with 0x00000000000005d0, which is the paddr of the `.plt` section. It's the original lineage of plt and got.

- iS
- !readelf -SW a.out
- !readelf -R .rela.plt -R .plt -R .got a.out
- !objdump -j .rela.plt -j .plt -j .got -s a.out
- !rabin2 -S a.out

Since *libc.so* is not loaded at the moment, the GOT relocs entry is not resolved. In other words, the dynamic symbol would only be resolved until its module is loaded.

## entry0 -> main

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

Disassemble 8 instructions backwards. The PLT stubs of the `.plt` section happen to be above *entry0*.

```bash
[0xaaaadc760640]> pd -8
            ;-- rsym.abort:
┌ 16: void sym.imp.abort ();
│ rg: 0 (vars 0, args 0)
│ bp: 0 (vars 0, args 0)
│ sp: 0 (vars 0, args 0)
│           0xaaaadc760620      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_ ; 0xaaaae6890000
│           0xaaaadc760624      11e247f9       ldr x17, [x16, 0xfc0]
│           0xaaaadc760628      10023f91       add x16, x16, 0xfc0
└           0xaaaadc76062c      20021fd6       br x17
            ;-- rsym.puts:
            ; CALL XREF from main @ 0xaaaadc76076c(x)
┌ 16: int sym.imp.puts (const char *s);
│ rg: 0 (vars 0, args 0)
│ bp: 0 (vars 0, args 0)
│ sp: 0 (vars 0, args 0)
│           0xaaaadc760630      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_ ; 0xaaaae6890000
│           0xaaaadc760634      11e647f9       ldr x17, [x16, 0xfc8]
│           0xaaaadc760638      10223f91       add x16, x16, 0xfc8
└           0xaaaadc76063c      20021fd6       br x17
```

### libc vmmap

Type `dmm` to check the latest modules.

1. We're now in the text segment of *a.out* - our main routine.
2. Dynamic library `libc.so` have been loaded at the moment.

```bash hl_lines="8"
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

## puts@plt

[Previously](./plt-puts-analysis.md), we've statically disassembled the `.plt` section using `objdump` command.

```bash
# objdump -j .plt -d a.out
$ objdump --disassemble=puts@plt a.out

a.out:     file format elf64-littleaarch64


Disassembly of section .init:

Disassembly of section .plt:

0000000000000630 <puts@plt>:
 630:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf770>
 634:	f947e611 	ldr	x17, [x16, #4040]
 638:	913f2210 	add	x16, x16, #0xfc8
 63c:	d61f0220 	br	x17
 640:	Address 0x0000000000000640 is out of bounds.


Disassembly of section .text:

Disassembly of section .fini:
```

As we can see, 0x10000+0xfc8 is the offset of `puts` in `.rela.plt` entries of `readelf -r a.out` and relocation records of `objdump -R a.out`.

The output of `rabin2 -R a.out` maybe more clear: the vaddr=0x00010fc8 is relative to virtual baddr, while the paddr=0x00000fc8 is relative to physical segment.

> `ADRP Xd, label`: label is an offset from the page address of this instruction.

### stub plug

Now, continue run until `rsym.puts`/`sym.imp.puts`. Then type `pdf` to see its disassembly in real time.

```bash
[0xaaaadc760754]> dcu sym.imp.puts
INFO: Continue until 0xaaaadc760630 using 4 bpsize
INFO: hit breakpoint at: 0xaaaadc760758
INFO: hit breakpoint at: 0xaaaadc760630
[0xaaaadc760630]> pdf
            ;-- rsym.puts:
            ;-- pc:
            ; CALL XREF from main @ 0xaaaadc76076c(x)
┌ 16: int sym.imp.puts (const char *s);
│           0xaaaadc760630      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_ ; 0xaaaadc770000
│           0xaaaadc760634      11e647f9       ldr x17, [x16, 0xfc8]
│           0xaaaadc760638      10223f91       add x16, x16, 0xfc8
└           0xaaaadc76063c      20021fd6       br x17
```

View the disassembly against `puts@plt`, it's easy to find that `10000 <__FRAME_END__+0xf770>` is dynamically replaced by `map._home_pifan_Projects_cpp_a.out.rw_`.

The [ADRP instruction](../arm/arm-adr-demo.md) is used to form the PC relative address to the 4KB page. As the PC is 0xaaaadc760630, its 4K page boundary aligned address (`:pg_hi21:`) is `0xaaaadc760000`, calculated by masking out the lower 12 bits.

> 0xaaaadc760000 is also the piebase and page address of the first text segment *LOAD0*. Look back to chapter *loaded modules* and *memory maps*.

If you add the coded PC literal 0x10000 to the page address 0xaaaadc760000, it becomes `0xaaaadc770000`.

The above inference was based on baddr and the segment of the current `ADRP` instruction (*LOAD0*), it results in PC-relative calculation `x16=load0_baddr+offset`.

On the other hand, as we've already mentioned, the offset 0x10000 is the increment of vaddr over paddr for the *LOAD1* data segment where the `.got` section is located. Therefore, from the point of view of the *LOAD1* segment, the page address of the `.got` entries already matches it.

So it's not surprising that the `ADRP` literal is fixed as `map._home_pifan_Projects_cpp_a.out.rw_` (see `dm`) at runtime. It represents the *LOAD1* segment starting at 0xaaaadc770000. That's `x16=load1_baddr` according to the results, which is not a coincidence.

Look at the next instruction `ldr x17, [x16, 0xfc8]!`, `x16:0xfc8` is the address of GOT entry for `puts`(aka `reloc.puts`). `x16`=0xaaaadc770000+0xfc8=0xaaaadc770fc8. Then `x17` will load the value stored in pointer `x16`(0xaaaadc770fc8). It matches the output of `ir` in chapter *imports/relocations*.

Step 3 instructions and it comes to the last instruction `br x17`.

```bash
[0xaaaadc760630]> ds 3
[0xaaaadc760630]> pdf
            ;-- rsym.puts:
            ; CALL XREF from main @ 0xaaaadc76076c(x)
┌ 16: int sym.imp.puts (const char *s);
│           0xaaaadc760630      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_ ; 0xaaaadc770000
│           0xaaaadc760634      11e647f9       ldr x17, [x16, 0xfc8]
│           0xaaaadc760638      10223f91       add x16, x16, 0xfc8
│           ;-- pc:
└           0xaaaadc76063c      20021fd6       br x17
```

Check register `x16` and `x17`:

```bash
[0xaaaadc760630]> dr?x16
0xaaaadc770fc8
[0xaaaadc760630]> ?v $r:x17
0xffff9832ae70
```

Try to dereference `x16` as pointer:

```bash
[0xaaaadc760630]> pxq $w @ 0xaaaadc770fc8
0xaaaadc770fc8  0x0000ffff9832ae70                       p.2.....
[0xaaaadc760630]> pfp @ 0xaaaadc770fc8
0xaaaadc770fc8 = (qword)0x0000ffff9832ae70
[0xaaaadc760630]> pfS @ 0xaaaadc770fc8
0xaaaadc770fc8 = 0xaaaadc770fc8 -> 0xffff9832ae70 "{"
```

Actually, when *libc.so* is loaded, the value of the pointer is immediately updated from `0x00000000000005d0` to `0x0000ffff9832ae70`.

> The `dbw` command is provided to add watchpoints. However, it doesn't work as well as expected.

Type `dmi` to list symbols of `libc.so` and grep symbol `puts`:

```bash
[0xaaaae5360630]> # dmi libc.so ~..
[0xaaaae5360630]> dmi libc.so ~puts

[Symbols]
nth paddr      vaddr          bind   type  size  lib name
――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

1400 0x0006ae70 0xffff9832ae70 WEAK   FUNC 492       puts
1409 0x0006ae70 0xffff9832ae70 GLOBAL FUNC 492       _IO_puts
```

The symbol `puts`(@GLIBC_2.17) is located exactly at `0xffff9832ae70`! Moreover, it's located between 0x0000ffff982c0000` - `0x0000ffff98448000, to which the text segment *LOAD0* is mapped.

Set a breakpoint at puts/0xffff9832ae70 and continue.

- [Cannot set breakpoints · Issue #12811](https://github.com/radareorg/radare2/issues/12811)
- [Radare2 can't set breakpoint?](https://reverseengineering.stackexchange.com/questions/13689/radare2-noob-question-cant-set-breakpoint)

```bash
[0xaaaadc760630]> db puts
WARN: base addr should not be larger than the breakpoint address
WARN: Cannot set breakpoint outside maps. Use dbg.bpinmaps to false
[0xaaaadc760630]> e dbg.bpinmaps
true
[0xaaaadc760630]> db 0xffff9832ae70; dc
INFO: hit breakpoint at: 0xffff9832ae70
```

The last instruction `br x17` jumps to `0xffff9832ae70`, which slides into `puts` in *libc.so*.

```bash
[0xffff9832ae70]> dm.
0x0000ffff982c0000 - 0x0000ffff98448000 - usr   1.5M s r-x /usr/lib/aarch64-linux-gnu/libc.so.6 /usr/lib/aarch64-linux-gnu/libc.so.6

[0xffff9832ae70]> pdf
ERROR: Cannot find function at 0xffff9832ae70
# analyze function at current address($$)
[0xffff9832ae70]> af; pdf
            ;-- x17:
            ;-- d17:
            ;-- pc:
┌ 424: fcn.ffff9799ae70 (int64_t arg1);
│           ; arg int64_t arg1 @ x0
│           ; var int64_t var_10h @ sp+0x10
│           ; var int64_t var_20h @ sp+0x20
│           ; var int64_t var_30h @ sp+0x30
│           0xffff9832ae70 b    fd7bbca9       stp x29, x30, [sp, -0x40]!
│           0xffff9832ae74      fd030091       mov x29, sp
│           0xffff9832ae78      f35301a9       stp x19, x20, [sp, 0x10]
│           0xffff9832ae7c      94090090       adrp x20, 0xffff9845a000 ; d24
│           0xffff9832ae80      f55b02a9       stp x21, x22, [sp, 0x20]
│           0xffff9832ae84      f60300aa       mov x22, x0
│           0xffff9832ae88      f76303a9       stp x23, x24, [sp, 0x30]
│           0xffff9832ae8c      8dba0094       bl 0xffff983598c0

            [...snip...]
```

Type `dc` to continue to the end.

```bash
[0xffff9832ae70]> dc
Hello, Linux!
(69048) Process exited with status=0x0
```

### libc/puts

Although everything is clear, we can do some confirmation from the shared library perspective.

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

Keep in mind the principle `VA = baddr+offset/RVA`.

According to the latest `dm` output(linkmap), the *Load Bias* of libc.so is 0xffff982c0000. It's also the start address of text segment *LOAD0* according to the latest `dmm` output(vmmap).

Add the paddr/offset to the baddr/bias to check the correctness of the formula.

```bash
[0xaaaadc760630]> ?v 0xffff982c0000+0x6ae70
0xffff9832ae70
```

The result is entirely consistent with our earlier research.

Nothing is out of the ordinary. Everything is working out as expected.
