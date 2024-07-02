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

On this post, we'll do much the same work, but change our dynamic analysis tool to the popular open-source SRE toolkit r2(aka [radare2](../toolchain/radare2-basics.md)).

It is also a thorough and comprehensive debugging exercise, demonstrating the power and versatility of the `r2` toolset.

<!-- more -->

Run the DYN ELF `a.out` with the `-d` and `-A` options using r2.

```bash
$ r2 -dA a.out
```

1. `-d`: debug the executable, behaved as `gdb -> starti`.
2. `-A` will run `aaa` command to analyze all referenced code.

Check program/process status info:

```bash
# list opened binary files and objid
[0xffff98492c40]> ob
* 0 3 arm-64 ba:0xaaaadc760640 sz:7078 /home/pifan/Projects/cpp/a.out

# show path to executable
[0xffff98492c40]> dpe
/home/pifan/Projects/cpp/a.out

# list current pid and children
[0xffff98492c40]> dp
INFO: Selected: 501878 501878
 * 501878 ppid:501854 uid:1000 s ./a.out

# show the current process id
[0xffff98492c40]> dpq
501878
```

## entry point vaddr

Check base address(`baddr`) and `paddr`/`vaddr` of entry point.

```bash
# see ba in `ob`
[0xffff98492c40]> i ~baddr
baddr    0xaaaadc760000
# same as dbg.baddr, progam base address
[0xffff98492c40]> ?v $DB
0xaaaadc760000
[0xffff98492c40]> rabin2 -eq a.out
0x00000640
[0xffff98492c40]> ieq
0xaaaadc760640
```

List CRT entries+constructors:

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

Show main function address.

```bash
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

Type `?w $$` or `?w pc` to show what's in current address.

```bash
[0xffff9fc44c40]> ?w pc
/usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 pc library R X 'bti c' 'ld-linux-aarch64.so.1'
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
# dpq get pid then !cat /proc/pid/maps
[0xffff98492c40]> dm
0x0000aaaadc760000 - 0x0000aaaadc761000 - usr     4K s r-x /home/pifan/Projects/cpp/a.out /home/pifan/Projects/cpp/a.out ; map._home_pifan_Projects_cpp_a.out.r_x
0x0000aaaadc770000 - 0x0000aaaadc772000 - usr     8K s rw- /home/pifan/Projects/cpp/a.out /home/pifan/Projects/cpp/a.out ; map._home_pifan_Projects_cpp_a.out.rw_
0x0000ffff9847b000 - 0x0000ffff984a6000 * usr   172K s r-x /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.r_x
0x0000ffff984b2000 - 0x0000ffff984b4000 - usr     8K s r-- [vvar] [vvar] ; map._vvar_.r__
0x0000ffff984b4000 - 0x0000ffff984b5000 - usr     4K s r-x [vdso] [vdso] ; map._vdso_.r_x
0x0000ffff984b5000 - 0x0000ffff984b9000 - usr    16K s rw- /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.rw_
0x0000ffffc7fcd000 - 0x0000ffffc7fee000 - usr   132K s rw- [stack] [stack] ; map._stack_.rw_
```

Evaluate `$D` and `$DD` to confirm current debug map info.

```bash
# current debug map base address
[0xffff98492c40]> ?v $D # @pc
0xffff9847b000
# current debug map size
[0xffff98492c40]> ?v $DD
0x2b000
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

Use `rabin2 -S` or `iS` to list sections.

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

Filter specified sections:

- !readelf -R .rela.plt -R .plt -R .got a.out
- !objdump -j .rela.plt -j .plt -j .got -s a.out

Use `rabin2 -SS` or `iSS` to view segments.

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

```bash hl_lines="9"
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

> `sym.` stands for *sym*bol, e.g., sym.main, sym.func.
> `imp.` stands for *imp*orted symbols like puts/scanf, to be relocated.
> `rsym.` stands for has-been-*r*elocated symbols like puts/scanf in libc.so.

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
```

Press ++tab++ after the dot to view automatic IntelliSense options.

```bash
[0xffff98492c40]> ?v sym.
sym._init                   sym.imp.__libc_start_main
sym.imp.__cxa_finalize      sym.imp.abort
sym.imp.puts                sym._start
sym.call_weak_fn            sym.deregister_tm_clones
sym.register_tm_clones      sym.__do_global_dtors_aux
sym.frame_dummy             sym.main
sym._fini

[0xffff98492c40]> ?v sym.imp.
sym.imp.__libc_start_main   sym.imp.__cxa_finalize      sym.imp.abort
sym.imp.puts

[0xffff98492c40]> ?v rsym.
rsym.__libc_start_main   rsym.__cxa_finalize      rsym.__gmon_start__
rsym.abort               rsym.puts
```

Inspect the address of the symbol.

```bash
# ii ~puts
[0xffff98492c40]> ?v rsym.puts # ?v sym.imp.puts # afo rsym.puts
0xaaaadc760630
```

### disassemble PLT

Using `iS` command to list sections and filter by name `.plt` :

```bash
[0xffff98492c40]> iS,name/eq/.plt
[Sections]

nth paddr       size vaddr           vsize perm type     name
―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
12  0x000005d0  0x70 0xaaaadc7605d0   0x70 -r-x PROGBITS .plt

[0xffff98492c40]> # iS,name/eq/.plt,c/cols/size
[0xffff98492c40]> # iS,name/eq/.plt,c/cols/size,:noheader
[0xffff98492c40]> iS,name/eq/.plt ~.plt[2] # grep size
0x70
[0xffff98492c40]> iS,name/eq/.plt ~.plt[3] # grep vaddr
0xaaaadc7605d0
```

Query the vaddr to inspect what's on it:

```bash
[0xffff98492c40]> # ?w 0xaaaadc7605d0
[0xffff98492c40]> ?w `iS,name/eq/.plt ~.plt[3]`
/home/pifan/Projects/cpp/a.out .plt section..plt program R X 'stp x16, x30, [sp, -0x10]!' 'a.out'
```

As shown above, the `.plt` section is labelled as `section..plt` by r2. Try to evaluate it:

```bash
[0xffff98492c40]> # ?w section..plt
[0xffff98492c40]> ?v section..plt
0xaaaadc7605d0
```

Disassemble the `.plt` section using `pd` command.

```bash hl_lines="37-41"
[0xffff98492c40]> # pd 0x70/$l @ section..plt
[0xffff98492c40]> pd `iS,name/eq/.plt ~.plt[2]`/$l @ `iS,name/eq/.plt ~.plt[3]`
   section..plt + 0              ;-- section..plt:
   section..plt + 0              0xaaaadc7605d0      f07bbfa9       stp x16, x30, [sp, -0x10]!
   section..plt + 4              0xaaaadc7605d4      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_
   section..plt + 8              0xaaaadc7605d8      11d247f9       ldr x17, [x16, 0xfa0]
   section..plt + 12             0xaaaadc7605dc      10823e91       add x16, x16, 0xfa0
   section..plt + 16             0xaaaadc7605e0      20021fd6       br x17
   section..plt + 20             0xaaaadc7605e4      1f2003d5       nop
   section..plt + 24             0xaaaadc7605e8      1f2003d5       nop
   section..plt + 28             0xaaaadc7605ec      1f2003d5       nop
   sym.imp.__libc_start_main + 0              ;-- rsym.__libc_start_main:
┌ 16: int sym.imp.__libc_start_main (func main, int argc, char **ubp_av, func init, func fini, func rtld_fini, void *stack_end); // noreturn
│  sym.imp.__libc_start_main + 0              0xaaaadc7605f0      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_
│  sym.imp.__libc_start_main + 4              0xaaaadc7605f4      11d647f9       ldr x17, [x16, 0xfa8]
│  sym.imp.__libc_start_main + 8              0xaaaadc7605f8      10a23e91       add x16, x16, 0xfa8
└  sym.imp.__libc_start_main + 12             0xaaaadc7605fc      20021fd6       br x17
   sym.imp.__cxa_finalize + 0              ;-- rsym.__cxa_finalize:
┌ 16: sym.imp.__cxa_finalize ();
│  sym.imp.__cxa_finalize + 0              0xaaaadc760600      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_
│  sym.imp.__cxa_finalize + 4              0xaaaadc760604      11da47f9       ldr x17, [x16, 0xfb0]
│  sym.imp.__cxa_finalize + 8              0xaaaadc760608      10c23e91       add x16, x16, 0xfb0
└  sym.imp.__cxa_finalize + 12             0xaaaadc76060c      20021fd6       br x17
   rsym.__gmon_start__ + 0              ;-- rsym.__gmon_start__:
   rsym.__gmon_start__ + 0              ;-- __gmon_start__:
   rsym.__gmon_start__ + 0              0xaaaadc760610      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_
   rsym.__gmon_start__ + 4              0xaaaadc760614      11de47f9       ldr x17, [x16, 0xfb8]
   rsym.__gmon_start__ + 8              0xaaaadc760618      10e23e91       add x16, x16, 0xfb8
   rsym.__gmon_start__ + 12             0xaaaadc76061c      20021fd6       br x17
   sym.imp.abort + 0              ;-- rsym.abort:
┌ 16: void sym.imp.abort ();
│  sym.imp.abort + 0              0xaaaadc760620      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_
│  sym.imp.abort + 4              0xaaaadc760624      11e247f9       ldr x17, [x16, 0xfc0]
│  sym.imp.abort + 8              0xaaaadc760628      10023f91       add x16, x16, 0xfc0
└  sym.imp.abort + 12             0xaaaadc76062c      20021fd6       br x17
   sym.imp.puts + 0              ;-- rsym.puts:
┌ 16: int sym.imp.puts (const char *s);
│  sym.imp.puts + 0              0xaaaadc760630      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_
│  sym.imp.puts + 4              0xaaaadc760634      11e647f9       ldr x17, [x16, 0xfc8]
│  sym.imp.puts + 8              0xaaaadc760638      10223f91       add x16, x16, 0xfc8
└  sym.imp.puts + 12             0xaaaadc76063c      20021fd6       br x17
```

### telescope GOT

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

Pay attention to the *paddr* column, it's the offset of `.got` entry.

Using `iS` command to list sections and filter by name `.got` :

```bash
[0xffff98492c40]> iS,name/eq/.got
[Sections]

nth paddr       size vaddr           vsize perm type     name
―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
21  0x00000f90  0x70 0xaaaad8d40f90   0x70 -rw- PROGBITS .got

[0xffff98492c40]> # iS,name/eq/.got,c/cols/size
[0xffff98492c40]> # iS,name/eq/.got,c/cols/size,:noheader
[0xffff98492c40]> iS,name/eq/.got ~.got[2] # grep size
0x70
[0xffff98492c40]> iS,name/eq/.got ~.got[3] # grep vaddr
0xaaaadc770f90
```

Query the vaddr to inspect what's on it:

```bash
[0xffff98492c40]> # ?w 0xaaaadc770f90
[0xffff98492c40]> ?w `iS,name/eq/.got ~.got[3]`
/home/pifan/Projects/cpp/a.out .got section..got program R W 0x0
```

As shown above, the `.got` section is labelled as `section..got` by r2. Try to evaluate it:

```bash
[0xffff98492c40]> # ?w section..got
[0xffff98492c40]> ?v section..got
0xaaaadc770f90
```

Show hexword references of `.got` section for telescoping:

```bash hl_lines="8"
[0xffff98492c40]> # xr $w*(0x70/8) @ section..got
[0xffff98492c40]> xr $w*(`iS,name/eq/.got ~.got[2]`/8) @ `iS,name/eq/.got ~.got[3]`
0xaaaadc770f90 ..[ null bytes ]..   00000000 section..got
0xaaaadc770fa8 0x00000000000005d0   ........ @ reloc.__libc_start_main 1488
0xaaaadc770fb0 0x00000000000005d0   ........ 1488
0xaaaadc770fb8 0x00000000000005d0   ........ 1488
0xaaaadc770fc0 0x00000000000005d0   ........ @ reloc.abort 1488
0xaaaadc770fc8 0x00000000000005d0   ........ @ reloc.puts 1488
0xaaaadc770fd0 0x0000000000010da0   ........ @ obj._GLOBAL_OFFSET_TABLE_ 69024
0xaaaadc770fd8 ..[ null bytes ]..   00000000 reloc._ITM_deregisterTMCloneTable
0xaaaadc770ff0 0x0000000000000754   T....... 1876
0xaaaadc770ff8 ..[ null bytes ]..   00000000 reloc._ITM_registerTMCloneTable
```

As we can see, the GOT entry for `puts@plt` is labelled as `reloc.puts` by r2, equivalent to `puts@got.plt` in pwndbg.

Press ++tab++ after the dot to view automatic IntelliSense options.

```bash
[0xffff98492c40]> ?v reloc.
reloc.__libc_start_main             reloc.abort
reloc.puts                          reloc._ITM_deregisterTMCloneTable
reloc.__cxa_finalize                reloc.__gmon_start__
reloc._ITM_registerTMCloneTable
```

Get the value(address) of label `reloc.puts` by evaluation:

```bash
# ir ~puts
[0xffff98492c40]> ?v reloc.puts # dumb afo still mutes
0xaaaadc770fc8
```

Use the `x` command to see what is stored at `reloc.puts`:

```bash
[0xffff98492c40]> pxq $w @ reloc.puts
0xaaaadc770fc8  0x00000000000005d0
```

According to the hexdump content of the `.got` section, it's originally filled with 0x00000000000005d0, which represents the *first* PLT stub(PLT[0], PLT header) of the `.plt` section in segment.LOAD0. It's the original lineage of plt and got.

> The offset to page `map._home_pifan_Projects_cpp_a.out.rw_`(segment.LOAD1) is `0xfa0`, corresponding to `GOT[2]`, which is reserved by `ld.so`.

Since *libc.so* is not loaded at the moment, the GOT relocs entry is not resolved. In other words, the dynamic symbol would only be resolved until its module is loaded.

## entry0 -> main

### dcu entry0

Continue until `entry0`(aka `_start`), refer to `entry point vaddr` and check:

```bash
[0xffff98492c40]> dcu entry0
INFO: Continue until 0xaaaadc760640 using 4 bpsize
INFO: hit breakpoint at: 0xaaaadc760640
```

Type `?w $$` or `?w pc` to confirm what's in current address.

```bash
[0xffff98492c40]> ?w pc
/home/pifan/Projects/cpp/a.out .text entry0,section..text,_start,x16,x21,pc,d16,d21 entry0 program R X 'nop' 'a.out'
```

Seek to pc and list current symbol:

```bash
[0xffff98492c40] s pc; is.
nth paddr      vaddr          bind  type size lib name  demangled
―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
13  0x00000640 0xaaaadc760640 LOCAL SECT 0        .text
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

*entry0*+28 \~ *entry0*+32 loads the value at `GOT`[0xff0]=*0xaaaadc770ff0. This corresponds to a static relocation entry of type `R_AARCH64_RELATIVE`, the value of which can be calculated by $reloc\_bias+addend$=0xaaaadc760754, resulting in `x0` pointing to the `main` function.

Disassemble 8 instructions backwards. The PLT stubs of the `.plt` section happen to be above *entry0*.

```bash
[0xaaaadc760640]> pd -8
            ;-- rsym.abort:
┌ 16: void sym.imp.abort ();
│ rg: 0 (vars 0, args 0)
│ bp: 0 (vars 0, args 0)
│ sp: 0 (vars 0, args 0)
│           0xaaaadc760620      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_ ; 0xaaaadc770000
│           0xaaaadc760624      11e247f9       ldr x17, [x16, 0xfc0]
│           0xaaaadc760628      10023f91       add x16, x16, 0xfc0
└           0xaaaadc76062c      20021fd6       br x17
            ;-- rsym.puts:
            ; CALL XREF from main @ 0xaaaadc76076c(x)
┌ 16: int sym.imp.puts (const char *s);
│ rg: 0 (vars 0, args 0)
│ bp: 0 (vars 0, args 0)
│ sp: 0 (vars 0, args 0)
│           0xaaaadc760630      90000090       adrp x16, map._home_pifan_Projects_cpp_a.out.rw_ ; 0xaaaadc770000
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

Evaluate `$D` and `$DD` to confirm current debug map base address and size.

```bash
[0xaaaadc760640]> ?v $D
0xaaaadc760000
[0xaaaadc760640]> ?v $DD
0x1000
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

### reloc GOT

Telescope `.got` section after dynamic linking:

```bash hl_lines="8"
# use xQ to see the whole section including empty slots(placeholders)
[0xaaaadc760640]> xr $w*(`iS,name/eq/.got ~.got[2]`/8) @ `iS,name/eq/.got ~.got[3]`
0xaaaadc770f90 ..[ null bytes ]..   00000000 section..got
0xaaaadc770fa8 0x0000ffff982e7434    4t[..... @ reloc.__libc_start_main
0xaaaadc770fb0 0x0000ffff982fd220    .\.....
0xaaaadc770fb8 ..[ null bytes ]..   00000000
0xaaaadc770fc0 0x0000ffff982e704c   Lp[..... @ reloc.abort
0xaaaadc770fc8 0x0000ffff9832ae70   p._..... @ reloc.puts
0xaaaadc770fd0 0x0000000000010da0   ........ @ obj._GLOBAL_OFFSET_TABLE_ 69024
0xaaaadc770fd8 ..[ null bytes ]..   00000000 reloc._ITM_deregisterTMCloneTable
0xaaaadc770fe0 0x0000ffff982fd220    .\..... @ reloc.__cxa_finalize
0xaaaadc770fe8 ..[ null bytes ]..   00000000 reloc.__gmon_start__
0xaaaadc770ff0 0x0000aaaadc760754   T....... /home/pifan/Projects/cpp/a.out .text main,main main program R X 'stp x29, x30, [sp, -0x20]!' 'a.out'
0xaaaadc770ff8 ..[ null bytes ]..   00000000 reloc._ITM_registerTMCloneTable
```

As the *libc.so* is loaded, the value of `reloc.puts`(offset=0xfc8) is immediately updated from `0x00000000000005d0` to `0x0000ffff9832ae70`(&puts@GLIBC).

### dcu main

Set a breakpoint at `main` and continue.

```bash
[0xaaaadc760640]> db main; dc
[+] SIGNAL 28 errno=0 addr=0x00000000 code=128 si_pid=0 ret=0
INFO: hit breakpoint at: 0xaaaadc760754
[+] signal 28 aka SIGWINCH received 0 (Window Changed Size)
```

Confirm what's up and disassemble function.

```bash
[0xaaaadc760754]> ?w pc
/home/pifan/Projects/cpp/a.out .text main,main,x3,x23,pc,d3,d23 main program R X 'stp x29, x30, [sp, -0x20]!' 'a.out'

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

Type `dcc` to continue until call `bl sym.imp.puts`.

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

!!! note "Intra-Procedure call scratch registers"

    Refer to [Register file of ARM64](../arm/a64-regs.md), [ABI & Calling conventions](../cs/calling-convention.md) - PCS, [ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) - 9.1 Register use in the AArch64 Procedure Call Standard.

    `X16` and `X17` are registers with a special purpose, predeclared as `IP0` and `IP1`. `IP` is abbrev for Intra-Procedure-Call.
    These can be used by call veneers and similar code, or as temporary registers for intermediate values between subroutine calls. They are corruptible by a function.
    **Veneers** are small pieces of code which are automatically inserted by the linker, for example when the branch target is out of range of the branch instruction. The PLT stub `puts@plt` is just such a vivid type of veneer.

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

View the disassembly against `puts@plt`, it's easy to find that the PC-relative literal 0x`10000 <__FRAME_END__+0xf770>` is dynamically replaced by `map._home_pifan_Projects_cpp_a.out.rw_`.

### reloc fixup

The [ADRP instruction](../arm/arm-adr-demo.md) is used to form the PC relative address to the 4KB page. As the PC is 0xaaaadc760630, its 4K page boundary aligned address (`:pg_hi21:`/`R_AARCH64_ADR_PREL_PG_HI21`) is `0xaaaadc760000`, calculated by masking out the lower 12 bits.

> 0xaaaadc760000 is also the piebase and page address of the first text segment *LOAD0*. Look back to chapter *loaded modules* and *memory maps*.

The above inference was based on baddr and the segment of the current `ADRP` instruction (*LOAD0*), it results in PC-relative calculation `x16=load0_baddr+offset`. On the other hand, as we've already mentioned, the offset `0x10000` is the increment of vaddr over paddr for the *LOAD1* data segment where the `.got` section is located.

So it's not surprising that the `ADRP` literal is fixed as `map._home_pifan_Projects_cpp_a.out.rw_` (see `dm`) at runtime. It represents segment.LOAD1 starting at 0xaaaadc770000(`R_AARCH64_ADR_GOT_PAGE`). That's `x16=load1_baddr` according to the results, which is not a coincidence.

!!! info "ADRP PC-relative literal equiv eval"

    1. `map._home_pifan_Projects_cpp_a.out.r_x`(segment.LOAD0) = 0xaaaadc760000, PC's seg page addr
    2. `map._home_pifan_Projects_cpp_a.out.rw_`(segment.LOAD1) = 0xaaaadc770000, GOT's seg page addr
    3. `segment.LOAD1` = `segment.LOAD0` + *0x10000*

    ```bash
    [0xaaaadc760630]> ?w pc
    /home/pifan/Projects/cpp/a.out .plt rsym.puts,puts,pc sym.imp.puts program R X 'adrp x16, 0xaaaadc770000' 'a.out'
    ```

Look at the next instruction `ldr x17, [x16, 0xfc8]!`, `0xfc8` is the offset of GOT entry for `puts`(aka `reloc.puts`). `x16`=0xaaaadc770000+0xfc8=0xaaaadc770fc8. Then `x17` will load the value(address) stored in pointer `x16`(0xaaaadc770fc8). It matches the output of `ir` in chapter *imports/relocations*.

### ADRP+LDR

Step 3 instructions and it comes to the last instruction `br x17`.

```bash
[0xaaaadc760630]> ds 3 # 3ds
[0xaaaadc760630]> s pc
[0xaaaadc76063c]> pdf
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

> `ai @addr`: show address information

```bash
[0xaaaadc76063c]> aij~{} @ x16 # ai @ x16
{
  "program": "true",
  "exec": "true",
  "read": "true",
  "flag": "true",
  "func": "true"
}
[0xaaaadc76063c]> dr?x16
0xaaaadc770fc8

[0xaaaadc76063c]> aij @ x17
{"library":"true","exec":"true","read":"true","flag":"true","reg":"true"}
[0xaaaadc76063c]> dr x17
0xffff9832ae70
```

Hexdump and dereference `x16`:

```bash
# pvp @ x16 # pv8 @ x16
[0xaaaadc76063c]> pv @ x16 # pv @ 0xaaaadc770fc8
0x0000ffff9cbbae70

# printf quadword: pf1q @ x16
# pointer reference with label: pfp puts_addr @ x16
# 64bit pointer to string: pfS @ x16
# show hexadecimal quad-words dump: pxq $w @ x16

[0xaaaadc76063c]> xQ $w @ x16
0xaaaadc770fc8  0x0000ffff9832ae70 x17
```

Inspect and telescope `x16`:

```bash
[0xaaaadc76063c]> ?w x16
/home/pifan/Projects/cpp/a.out .got reloc.puts,x16,d16 program R 0xffff9832ae70
[0xaaaadc76063c]> xr $w @ x16
0xaaaadc770fc8  0x0000ffff9832ae70   p....... @ d16 /usr/lib/aarch64-linux-gnu/libc.so.6 x17,d17 library R X 'stp x29, x30, [sp, -0x40]!' 'libc.so.6'
[0xaaaadc76063c]> drr~x16
     x16    0xaaaadc770fc8     /home/pifan/Projects/cpp/a.out .got reloc.puts,x16,d16 program R 0xffff9832ae70
```

!!! warning "r2 watchpoints"

    The `dbw` command is provided to add watchpoints. However, it doesn't work as well as expected, see related [issue](https://github.com/radareorg/radare2/issues/11029).

Inspect and telescope `x17`:

```bash
[0xaaaadc76063c]> ?w x17
/usr/lib/aarch64-linux-gnu/libc.so.6 x17,d17 library R X 'stp x29, x30, [sp, -0x40]!' 'libc.so.6'
[0xaaaadc76063c]> drr~x17 # xr $w @ x17
     x17    0xffff9832ae70     /usr/lib/aarch64-linux-gnu/libc.so.6 x17,d17 library R X 'stp x29, x30, [sp, -0x40]!' 'libc.so.6'
```

Attempt to analyze instruction resides in `x17`.

```bash
[0xaaaadc76063c]> pfD @ x17 # pi 1 @ x17
stp x29, x30, [sp, -0x40]!

[0xaaaadc76063c]> pd 1 @ x17
            ;-- x17:
            ;-- d17:
            0xffffa5e1ae70      fd7bbca9       stp x29, x30, [sp, -0x40]!
```

### br x17

Type `dmi` to list symbols of `libc.so` and grep symbol `puts`:

```bash
[0xaaaadc76063c]> # dmi libc ~..
[0xaaaadc76063c]> dmi libc ~puts # dmi libc puts ~ puts$

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
[0xaaaadc76063c]> db puts
WARN: base addr should not be larger than the breakpoint address
WARN: Cannot set breakpoint outside maps. Use dbg.bpinmaps to false
[0xaaaadc76063c]> e dbg.bpinmaps
true
[0xaaaadc76063c]> db x17; dc
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

List function variables and arguments with disasm refs:

```bash
[0xffff9799ae70]> afv=
* arg1
R 0xffff9799ae84  mov x22, x0
* var_10h
R 0xffff9799afa8  ldp x19, x20, [var_10h]
* var_20h
R 0xffff9799afac  ldp x21, x22, [var_20h]
* var_30h
R 0xffff9799afb0  ldp x23, x24, [var_30h]

[0xffff9799ae70]> afvf # BP relative stackframe variables
0x00000030  var_10h:   int64_t
0x00000020  var_20h:   int64_t
0x00000010  var_30h:   int64_t
0xffffffffffffff9a  arg1:      int64_t

[0xffff9799ae70]> afvr # register based arguments
arg int64_t arg1 @ x0

[0xffff9799ae70]> afvs # sp based arguments/locals
var int64_t var_10h @ sp+0x10
var int64_t var_20h @ sp+0x20
var int64_t var_30h @ sp+0x30
```

Inspect register based argument `X0`(stuff to *puts*):

```bash
[0xffff9799ae70]> ?w x0
/home/pifan/Projects/cpp/a.out .rodata str.Hello__Linux_,x0,d0 program R X 'ldnp d8, d25, [x10, -0x140]' 'a.out' Hello, Linux!
[0xffff9799ae70]> ps @ x0
Hello, Linux!
```

Type `dc` to continue to the end.

```bash
[0xffff9832ae70]> dc
Hello, Linux!
(501878) Process exited with status=0x0
```

## puts@GLIBC

Although everything is clear, we can do some confirmation from the so(*s*hared *o*bject) perspective.

Let's look up symbol `puts` in libc.so.6, the weak symbol `puts` will be overriden by the global symbol `_IO_puts`.

```bash
[0xaaaadc76063c]> !nm -gD /usr/lib/aarch64-linux-gnu/libc.so.6 | grep puts

000000000006ae70 T _IO_puts@@GLIBC_2.17
000000000006ae70 W puts@@GLIBC_2.17

[0xaaaadc76063c]> !readelf -s /usr/lib/aarch64-linux-gnu/libc.so.6 | grep puts

   Num:    Value          Size Type    Bind   Vis      Ndx Name

  1400: 000000000006ae70   492 FUNC    WEAK   DEFAULT   12 puts@@GLIBC_2.17
  1409: 000000000006ae70   492 FUNC    GLOBAL DEFAULT   12 _IO_puts@@GLIBC_2.17

[0xaaaadc76063c]> !objdump -t /usr/lib/aarch64-linux-gnu/libc.so.6 | grep puts

000000000006ae70  w    F .text	00000000000001ec puts
000000000006ae70 g     F .text	00000000000001ec _IO_puts
```

The value of the symbol `puts` is `000000000006ae70`, which is the static absolute paddr and will be adjusted to vaddr when loaded into memory.

Keep in mind the principle `VA = baddr+offset/RVA`.

According to the latest `dm` output(linkmap), the *Load Bias* of libc.so is 0xffff982c0000. It's also the start address of segment.LOAD0 according to the latest `dmm` output(vmmap).

Add the paddr/offset to the baddr/bias to check the correctness of the formula.

```bash
[0xaaaadc76063c]> rax2 -k 0xffff982c0000+0x6ae70
[0xaaaadc76063c]> ?v 0xffff982c0000+0x6ae70
0xffff9832ae70
```

The result is entirely consistent with our earlier research. It's exactly the final jump target of `puts@plt`!

Nothing is out of the ordinary. Everything is working out as expected.
