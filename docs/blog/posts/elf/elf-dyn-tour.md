---
title: DYN ELF Walkthrough
authors:
    - xman
date:
    created: 2023-06-25T11:00:00
categories:
    - elf
comments: true
---

[Previously](./gcc-compilation-dynamic.md) we've compiled our C demo program with `gcc` command. It links dynamically by default.

In this article, I'll practice using [GNU binutils](./gnu-binutils.md) to take a close look at the `a.out` product.

<!-- more -->

## ELF Header

Now, let's check the [ELF](./elf-layout.md) header.

From the output of `file a.out`, we're informed that the ELF is dynamically linked, requires interpreter `/lib/ld-linux-aarch64.so.1` to load and run. The output of `readelf -h` also confirms this point, the Type is `DYN` (Position-Independent Executable file).

```bash
$ file a.out
a.out: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=429e4cbff3d62b27c644cef2b8aaf62d380b9690, for GNU/Linux 3.7.0, not stripped

$ objdump -f a.out

a.out:     file format elf64-littleaarch64
architecture: aarch64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x0000000000000640

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

The output of `objdump -f` shows that the BFD format specific flags are `HAS_SYMS, DYNAMIC, D_PAGED`.

## GCC pie/pic

[GCC - Code Gen Options](https://gcc.gnu.org/onlinedocs/gcc/Code-Gen-Options.html):

- `-fpic` / `-fPIC`
- `-fpie|-fPIE`
- `-fno-plt`

[GCC - Link Options](https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html): 

- `-flinker-output`=*type* = {exec, dyn, pie, rel, nolto-rel}
- `-pie` / `-no-pie` / `-static-pie`

[GCC Compilation Quick Tour - dynamic](../elf/gcc-compilation-dynamic.md): [collect2](https://gcc.gnu.org/onlinedocs/gccint/Collect2.html)/[LD](https://sourceware.org/binutils/docs/ld/Options.html) `-pie`

`-no-pie`: Create a position dependent executable. This is the *default*.

`-pie|--pic-executable`: Create a [position independent](https://en.wikipedia.org/wiki/Position-independent_code) executable. This is currently only supported on ELF platforms. Position independent executables are similar to shared libraries in that they are *relocated* by the dynamic linker to the virtual address the OS chooses for them (which can vary between invocations). Like normal dynamically linked executables they can be executed and symbols defined in the executable cannot be overridden by shared libraries.

[ARM (LD)](https://sourceware.org/binutils/docs/ld/ARM.html) - The `--pic-veneer` switch makes the linker use PIC sequences for ARM/Thumb interworking veneers, even if the rest of the binary is not PIC. This avoids problems on uClinux targets where `--emit-relocs` is used to generate relocatable binaries.

## section header

1. `readelf [-S|--section-headers|--sections]`: Display the sections' header.
2. `objdump [-h|--section-headers|--headers]`: Display the contents of the section headers.
3. `size`: Displays the sizes of sections inside binary files.

=== "readelf -SW a.out"

    ```bash
    $ readelf -SW a.out
    There are 28 section headers, starting at offset 0x1ba8:

    Section Headers:
    [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
    [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
    [ 1] .interp           PROGBITS        0000000000000238 000238 00001b 00   A  0   0  1
    [ 2] .note.gnu.build-id NOTE            0000000000000254 000254 000024 00   A  0   0  4
    [ 3] .note.ABI-tag     NOTE            0000000000000278 000278 000020 00   A  0   0  4
    [ 4] .gnu.hash         GNU_HASH        0000000000000298 000298 00001c 00   A  5   0  8
    [ 5] .dynsym           DYNSYM          00000000000002b8 0002b8 0000f0 18   A  6   3  8
    [ 6] .dynstr           STRTAB          00000000000003a8 0003a8 000092 00   A  0   0  1
    [ 7] .gnu.version      VERSYM          000000000000043a 00043a 000014 02   A  5   0  2
    [ 8] .gnu.version_r    VERNEED         0000000000000450 000450 000030 00   A  6   1  8
    [ 9] .rela.dyn         RELA            0000000000000480 000480 0000c0 18   A  5   0  8
    [10] .rela.plt         RELA            0000000000000540 000540 000078 18  AI  5  21  8
    [11] .init             PROGBITS        00000000000005b8 0005b8 000018 00  AX  0   0  4
    [12] .plt              PROGBITS        00000000000005d0 0005d0 000070 00  AX  0   0 16
    [13] .text             PROGBITS        0000000000000640 000640 00013c 00  AX  0   0 64
    [14] .fini             PROGBITS        000000000000077c 00077c 000014 00  AX  0   0  4
    [15] .rodata           PROGBITS        0000000000000790 000790 000016 00   A  0   0  8
    [16] .eh_frame_hdr     PROGBITS        00000000000007a8 0007a8 00003c 00   A  0   0  4
    [17] .eh_frame         PROGBITS        00000000000007e8 0007e8 0000ac 00   A  0   0  8
    [18] .init_array       INIT_ARRAY      0000000000010d90 000d90 000008 08  WA  0   0  8
    [19] .fini_array       FINI_ARRAY      0000000000010d98 000d98 000008 08  WA  0   0  8
    [20] .dynamic          DYNAMIC         0000000000010da0 000da0 0001f0 10  WA  6   0  8
    [21] .got              PROGBITS        0000000000010f90 000f90 000070 08  WA  0   0  8
    [22] .data             PROGBITS        0000000000011000 001000 000010 00  WA  0   0  8
    [23] .bss              NOBITS          0000000000011010 001010 000008 00  WA  0   0  1
    [24] .comment          PROGBITS        0000000000000000 001010 00002b 01  MS  0   0  1
    [25] .symtab           SYMTAB          0000000000000000 001040 000840 18     26  65  8
    [26] .strtab           STRTAB          0000000000000000 001880 00022c 00      0   0  1
    [27] .shstrtab         STRTAB          0000000000000000 001aac 0000fa 00      0   0  1
    Key to Flags:
    W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
    L (link order), O (extra OS processing required), G (group), T (TLS),
    C (compressed), x (unknown), o (OS specific), E (exclude),
    D (mbind), p (processor specific)
    ```

=== "objdump -hw a.out"

    ```bash
    $ objdump -hw a.out

    a.out:     file format elf64-littleaarch64

    Sections:
    Idx Name               Size      VMA               LMA               File off  Algn  Flags
    0 .interp            0000001b  0000000000000238  0000000000000238  00000238  2**0  CONTENTS, ALLOC, LOAD, READONLY, DATA
    1 .note.gnu.build-id 00000024  0000000000000254  0000000000000254  00000254  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
    2 .note.ABI-tag      00000020  0000000000000278  0000000000000278  00000278  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
    3 .gnu.hash          0000001c  0000000000000298  0000000000000298  00000298  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
    4 .dynsym            000000f0  00000000000002b8  00000000000002b8  000002b8  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
    5 .dynstr            00000092  00000000000003a8  00000000000003a8  000003a8  2**0  CONTENTS, ALLOC, LOAD, READONLY, DATA
    6 .gnu.version       00000014  000000000000043a  000000000000043a  0000043a  2**1  CONTENTS, ALLOC, LOAD, READONLY, DATA
    7 .gnu.version_r     00000030  0000000000000450  0000000000000450  00000450  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
    8 .rela.dyn          000000c0  0000000000000480  0000000000000480  00000480  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
    9 .rela.plt          00000078  0000000000000540  0000000000000540  00000540  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
    10 .init              00000018  00000000000005b8  00000000000005b8  000005b8  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
    11 .plt               00000070  00000000000005d0  00000000000005d0  000005d0  2**4  CONTENTS, ALLOC, LOAD, READONLY, CODE
    12 .text              0000013c  0000000000000640  0000000000000640  00000640  2**6  CONTENTS, ALLOC, LOAD, READONLY, CODE
    13 .fini              00000014  000000000000077c  000000000000077c  0000077c  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
    14 .rodata            00000016  0000000000000790  0000000000000790  00000790  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
    15 .eh_frame_hdr      0000003c  00000000000007a8  00000000000007a8  000007a8  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
    16 .eh_frame          000000ac  00000000000007e8  00000000000007e8  000007e8  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
    17 .init_array        00000008  0000000000010d90  0000000000010d90  00000d90  2**3  CONTENTS, ALLOC, LOAD, DATA
    18 .fini_array        00000008  0000000000010d98  0000000000010d98  00000d98  2**3  CONTENTS, ALLOC, LOAD, DATA
    19 .dynamic           000001f0  0000000000010da0  0000000000010da0  00000da0  2**3  CONTENTS, ALLOC, LOAD, DATA
    20 .got               00000070  0000000000010f90  0000000000010f90  00000f90  2**3  CONTENTS, ALLOC, LOAD, DATA
    21 .data              00000010  0000000000011000  0000000000011000  00001000  2**3  CONTENTS, ALLOC, LOAD, DATA
    22 .bss               00000008  0000000000011010  0000000000011010  00001010  2**0  ALLOC
    23 .comment           0000002b  0000000000000000  0000000000000000  00001010  2**0  CONTENTS, READONLY
    ```

=== "size -Ax a.out"

    ```bash
    $ size -Ax a.out
    a.out  :
    section               size      addr
    .interp               0x1b     0x238
    .note.gnu.build-id    0x24     0x254
    .note.ABI-tag         0x20     0x278
    .gnu.hash             0x1c     0x298
    .dynsym               0xf0     0x2b8
    .dynstr               0x92     0x3a8
    .gnu.version          0x14     0x43a
    .gnu.version_r        0x30     0x450
    .rela.dyn             0xc0     0x480
    .rela.plt             0x78     0x540
    .init                 0x18     0x5b8
    .plt                  0x70     0x5d0
    .text                0x13c     0x640
    .fini                 0x14     0x77c
    .rodata               0x16     0x790
    .eh_frame_hdr         0x3c     0x7a8
    .eh_frame             0xac     0x7e8
    .init_array            0x8   0x10d90
    .fini_array            0x8   0x10d98
    .dynamic             0x1f0   0x10da0
    .got                  0x70   0x10f90
    .data                 0x10   0x11000
    .bss                   0x8   0x11010
    .comment              0x2b       0x0
    Total                0x902
    ```

## symbol table

1. `readelf [-s|--syms|--symbols]`: Displays the entries in symbol table section of the file, if it has one. If a symbol has version information associated with it then this is displayed as well.
2. `objdump [-t|--syms]`: Print the symbol table entries of the file. This is similar to the information provided by the `nm` program, although the display format is different.
3. `nm` - list symbols from object files.

The only thing 0701.c does is call `printf("Hello, Linux!\n");` to print a string to the stdout device.
As we can see below, the compiler introspects that we just want to print a plain string without format specifier and va_list, so it optimises the `printf` to equivalent `puts`.

- [c - Compiler changes printf to puts - Stack Overflow](https://stackoverflow.com/questions/60080021/compiler-changes-printf-to-puts)
- [Patch to add __builtin_printf("string\n") -> puts("string")](https://gcc.gnu.org/legacy-ml/gcc-patches/2000-09/msg00921.html)

=== "readelf -s a.out"

    ```bash
    $ readelf -s a.out

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

    Symbol table '.symtab' contains 88 entries:
    Num:    Value          Size Type    Bind   Vis      Ndx Name
        0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
        1: 0000000000000238     0 SECTION LOCAL  DEFAULT    1 .interp
        2: 0000000000000254     0 SECTION LOCAL  DEFAULT    2 .note.gnu.build-id
        3: 0000000000000278     0 SECTION LOCAL  DEFAULT    3 .note.ABI-tag
        4: 0000000000000298     0 SECTION LOCAL  DEFAULT    4 .gnu.hash
        5: 00000000000002b8     0 SECTION LOCAL  DEFAULT    5 .dynsym
        6: 00000000000003a8     0 SECTION LOCAL  DEFAULT    6 .dynstr
        7: 000000000000043a     0 SECTION LOCAL  DEFAULT    7 .gnu.version
        8: 0000000000000450     0 SECTION LOCAL  DEFAULT    8 .gnu.version_r
        9: 0000000000000480     0 SECTION LOCAL  DEFAULT    9 .rela.dyn
        10: 0000000000000540     0 SECTION LOCAL  DEFAULT   10 .rela.plt
        11: 00000000000005b8     0 SECTION LOCAL  DEFAULT   11 .init
        12: 00000000000005d0     0 SECTION LOCAL  DEFAULT   12 .plt
        13: 0000000000000640     0 SECTION LOCAL  DEFAULT   13 .text
        14: 000000000000077c     0 SECTION LOCAL  DEFAULT   14 .fini
        15: 0000000000000790     0 SECTION LOCAL  DEFAULT   15 .rodata
        16: 00000000000007a8     0 SECTION LOCAL  DEFAULT   16 .eh_frame_hdr
        17: 00000000000007e8     0 SECTION LOCAL  DEFAULT   17 .eh_frame
        18: 0000000000010d90     0 SECTION LOCAL  DEFAULT   18 .init_array
        19: 0000000000010d98     0 SECTION LOCAL  DEFAULT   19 .fini_array
        20: 0000000000010da0     0 SECTION LOCAL  DEFAULT   20 .dynamic
        21: 0000000000010f90     0 SECTION LOCAL  DEFAULT   21 .got
        22: 0000000000011000     0 SECTION LOCAL  DEFAULT   22 .data
        23: 0000000000011010     0 SECTION LOCAL  DEFAULT   23 .bss
        24: 0000000000000000     0 SECTION LOCAL  DEFAULT   24 .comment
        25: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS Scrt1.o
        26: 0000000000000278     0 NOTYPE  LOCAL  DEFAULT    3 $d
        27: 0000000000000278    32 OBJECT  LOCAL  DEFAULT    3 __abi_tag
        28: 0000000000000640     0 NOTYPE  LOCAL  DEFAULT   13 $x
        29: 00000000000007fc     0 NOTYPE  LOCAL  DEFAULT   17 $d
        30: 0000000000000790     0 NOTYPE  LOCAL  DEFAULT   15 $d
        31: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS crti.o
        32: 0000000000000674     0 NOTYPE  LOCAL  DEFAULT   13 $x
        33: 0000000000000674    20 FUNC    LOCAL  DEFAULT   13 call_weak_fn
        34: 00000000000005b8     0 NOTYPE  LOCAL  DEFAULT   11 $x
        35: 000000000000077c     0 NOTYPE  LOCAL  DEFAULT   14 $x
        36: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS crtn.o
        37: 00000000000005c8     0 NOTYPE  LOCAL  DEFAULT   11 $x
        38: 0000000000000788     0 NOTYPE  LOCAL  DEFAULT   14 $x
        39: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS crtstuff.c
        40: 0000000000000690     0 NOTYPE  LOCAL  DEFAULT   13 $x
        41: 0000000000000690     0 FUNC    LOCAL  DEFAULT   13 deregister_tm_clones
        42: 00000000000006c0     0 FUNC    LOCAL  DEFAULT   13 register_tm_clones
        43: 0000000000011008     0 NOTYPE  LOCAL  DEFAULT   22 $d
        44: 0000000000000700     0 FUNC    LOCAL  DEFAULT   13 __do_global_dtors_aux
        45: 0000000000011010     1 OBJECT  LOCAL  DEFAULT   23 completed.0
        46: 0000000000010d98     0 NOTYPE  LOCAL  DEFAULT   19 $d
        47: 0000000000010d98     0 OBJECT  LOCAL  DEFAULT   19 __do_global_dtor[...]
        48: 0000000000000750     0 FUNC    LOCAL  DEFAULT   13 frame_dummy
        49: 0000000000010d90     0 NOTYPE  LOCAL  DEFAULT   18 $d
        50: 0000000000010d90     0 OBJECT  LOCAL  DEFAULT   18 __frame_dummy_in[...]
        51: 0000000000000810     0 NOTYPE  LOCAL  DEFAULT   17 $d
        52: 0000000000011010     0 NOTYPE  LOCAL  DEFAULT   23 $d
        53: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS 0701.c
        54: 0000000000000798     0 NOTYPE  LOCAL  DEFAULT   15 $d
        55: 0000000000000754     0 NOTYPE  LOCAL  DEFAULT   13 $x
        56: 0000000000000870     0 NOTYPE  LOCAL  DEFAULT   17 $d
        57: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS crtstuff.c
        58: 0000000000000890     0 NOTYPE  LOCAL  DEFAULT   17 $d
        59: 0000000000000890     0 OBJECT  LOCAL  DEFAULT   17 __FRAME_END__
        60: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS
        61: 0000000000010da0     0 OBJECT  LOCAL  DEFAULT  ABS _DYNAMIC
        62: 00000000000007a8     0 NOTYPE  LOCAL  DEFAULT   16 __GNU_EH_FRAME_HDR
        63: 0000000000010fd0     0 OBJECT  LOCAL  DEFAULT  ABS _GLOBAL_OFFSET_TABLE_
        64: 00000000000005d0     0 NOTYPE  LOCAL  DEFAULT   12 $x
        65: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __libc_start_mai[...]
        66: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_deregisterT[...]
        67: 0000000000011000     0 NOTYPE  WEAK   DEFAULT   22 data_start
        68: 0000000000011010     0 NOTYPE  GLOBAL DEFAULT   23 __bss_start__
        69: 0000000000000000     0 FUNC    WEAK   DEFAULT  UND __cxa_finalize@G[...]
        70: 0000000000011018     0 NOTYPE  GLOBAL DEFAULT   23 _bss_end__
        71: 0000000000011010     0 NOTYPE  GLOBAL DEFAULT   22 _edata
        72: 000000000000077c     0 FUNC    GLOBAL HIDDEN    14 _fini
        73: 0000000000011018     0 NOTYPE  GLOBAL DEFAULT   23 __bss_end__
        74: 0000000000011000     0 NOTYPE  GLOBAL DEFAULT   22 __data_start
        75: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__
        76: 0000000000011008     0 OBJECT  GLOBAL HIDDEN    22 __dso_handle
        77: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND abort@GLIBC_2.17
        78: 0000000000000790     4 OBJECT  GLOBAL DEFAULT   15 _IO_stdin_used
        79: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND puts@GLIBC_2.17
        80: 0000000000011018     0 NOTYPE  GLOBAL DEFAULT   23 _end
        81: 0000000000000640    52 FUNC    GLOBAL DEFAULT   13 _start
        82: 0000000000011018     0 NOTYPE  GLOBAL DEFAULT   23 __end__
        83: 0000000000011010     0 NOTYPE  GLOBAL DEFAULT   23 __bss_start
        84: 0000000000000754    40 FUNC    GLOBAL DEFAULT   13 main
        85: 0000000000011010     0 OBJECT  GLOBAL HIDDEN    22 __TMC_END__
        86: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_registerTMC[...]
        87: 00000000000005b8     0 FUNC    GLOBAL HIDDEN    11 _init
    ```

=== "objdump -t a.out"

    ```bash
    $ objdump -t a.out

    a.out:     file format elf64-littleaarch64

    SYMBOL TABLE:
    0000000000000238 l    d  .interp	0000000000000000              .interp
    0000000000000254 l    d  .note.gnu.build-id	0000000000000000              .note.gnu.build-id
    0000000000000278 l    d  .note.ABI-tag	0000000000000000              .note.ABI-tag
    0000000000000298 l    d  .gnu.hash	0000000000000000              .gnu.hash
    00000000000002b8 l    d  .dynsym	0000000000000000              .dynsym
    00000000000003a8 l    d  .dynstr	0000000000000000              .dynstr
    000000000000043a l    d  .gnu.version	0000000000000000              .gnu.version
    0000000000000450 l    d  .gnu.version_r	0000000000000000              .gnu.version_r
    0000000000000480 l    d  .rela.dyn	0000000000000000              .rela.dyn
    0000000000000540 l    d  .rela.plt	0000000000000000              .rela.plt
    00000000000005b8 l    d  .init	0000000000000000              .init
    00000000000005d0 l    d  .plt	0000000000000000              .plt
    0000000000000640 l    d  .text	0000000000000000              .text
    000000000000077c l    d  .fini	0000000000000000              .fini
    0000000000000790 l    d  .rodata	0000000000000000              .rodata
    00000000000007a8 l    d  .eh_frame_hdr	0000000000000000              .eh_frame_hdr
    00000000000007e8 l    d  .eh_frame	0000000000000000              .eh_frame
    0000000000010d90 l    d  .init_array	0000000000000000              .init_array
    0000000000010d98 l    d  .fini_array	0000000000000000              .fini_array
    0000000000010da0 l    d  .dynamic	0000000000000000              .dynamic
    0000000000010f90 l    d  .got	0000000000000000              .got
    0000000000011000 l    d  .data	0000000000000000              .data
    0000000000011010 l    d  .bss	0000000000000000              .bss
    0000000000000000 l    d  .comment	0000000000000000              .comment
    0000000000000000 l    df *ABS*	0000000000000000              Scrt1.o
    0000000000000278 l     O .note.ABI-tag	0000000000000020              __abi_tag
    0000000000000000 l    df *ABS*	0000000000000000              crti.o
    0000000000000674 l     F .text	0000000000000014              call_weak_fn
    0000000000000000 l    df *ABS*	0000000000000000              crtn.o
    0000000000000000 l    df *ABS*	0000000000000000              crtstuff.c
    0000000000000690 l     F .text	0000000000000000              deregister_tm_clones
    00000000000006c0 l     F .text	0000000000000000              register_tm_clones
    0000000000000700 l     F .text	0000000000000000              __do_global_dtors_aux
    0000000000011010 l     O .bss	0000000000000001              completed.0
    0000000000010d98 l     O .fini_array	0000000000000000              __do_global_dtors_aux_fini_array_entry
    0000000000000750 l     F .text	0000000000000000              frame_dummy
    0000000000010d90 l     O .init_array	0000000000000000              __frame_dummy_init_array_entry
    0000000000000000 l    df *ABS*	0000000000000000              0701.c
    0000000000000000 l    df *ABS*	0000000000000000              crtstuff.c
    0000000000000890 l     O .eh_frame	0000000000000000              __FRAME_END__
    0000000000000000 l    df *ABS*	0000000000000000
    0000000000010da0 l     O *ABS*	0000000000000000              _DYNAMIC
    00000000000007a8 l       .eh_frame_hdr	0000000000000000              __GNU_EH_FRAME_HDR
    0000000000010fd0 l     O *ABS*	0000000000000000              _GLOBAL_OFFSET_TABLE_
    0000000000000000       F *UND*	0000000000000000              __libc_start_main@GLIBC_2.34
    0000000000000000  w      *UND*	0000000000000000              _ITM_deregisterTMCloneTable
    0000000000011000  w      .data	0000000000000000              data_start
    0000000000011010 g       .bss	0000000000000000              __bss_start__
    0000000000000000  w    F *UND*	0000000000000000              __cxa_finalize@GLIBC_2.17
    0000000000011018 g       .bss	0000000000000000              _bss_end__
    0000000000011010 g       .data	0000000000000000              _edata
    000000000000077c g     F .fini	0000000000000000              .hidden _fini
    0000000000011018 g       .bss	0000000000000000              __bss_end__
    0000000000011000 g       .data	0000000000000000              __data_start
    0000000000000000  w      *UND*	0000000000000000              __gmon_start__
    0000000000011008 g     O .data	0000000000000000              .hidden __dso_handle
    0000000000000000       F *UND*	0000000000000000              abort@GLIBC_2.17
    0000000000000790 g     O .rodata	0000000000000004              _IO_stdin_used
    0000000000000000       F *UND*	0000000000000000              puts@GLIBC_2.17
    0000000000011018 g       .bss	0000000000000000              _end
    0000000000000640 g     F .text	0000000000000034              _start
    0000000000011018 g       .bss	0000000000000000              __end__
    0000000000011010 g       .bss	0000000000000000              __bss_start
    0000000000000754 g     F .text	0000000000000028              main
    0000000000011010 g     O .data	0000000000000000              .hidden __TMC_END__
    0000000000000000  w      *UND*	0000000000000000              _ITM_registerTMCloneTable
    00000000000005b8 g     F .init	0000000000000000              .hidden _init
    ```

=== "nm a.out"

    ```bash
    $ nm a.out
    0000000000000278 r __abi_tag
                    U abort@GLIBC_2.17
    0000000000011018 B __bss_end__
    0000000000011018 B _bss_end__
    0000000000011010 B __bss_start
    0000000000011010 B __bss_start__
    0000000000000674 t call_weak_fn
    0000000000011010 b completed.0
                    w __cxa_finalize@GLIBC_2.17
    0000000000011000 D __data_start
    0000000000011000 W data_start
    0000000000000690 t deregister_tm_clones
    0000000000000700 t __do_global_dtors_aux
    0000000000010d98 d __do_global_dtors_aux_fini_array_entry
    0000000000011008 D __dso_handle
    0000000000010da0 a _DYNAMIC
    0000000000011010 D _edata
    0000000000011018 B __end__
    0000000000011018 B _end
    000000000000077c T _fini
    0000000000000750 t frame_dummy
    0000000000010d90 d __frame_dummy_init_array_entry
    0000000000000890 r __FRAME_END__
    0000000000010fd0 a _GLOBAL_OFFSET_TABLE_
                    w __gmon_start__
    00000000000007a8 r __GNU_EH_FRAME_HDR
    00000000000005b8 T _init
    0000000000000790 R _IO_stdin_used
                    w _ITM_deregisterTMCloneTable
                    w _ITM_registerTMCloneTable
                    U __libc_start_main@GLIBC_2.34
    0000000000000754 T main
                    U puts@GLIBC_2.17
    00000000000006c0 t register_tm_clones
    0000000000000640 T _start
    0000000000011010 D __TMC_END__
    ```

## program Header

We can also type `readelf -l` to display the information contained in the file's segment headers.

> The section-to-segment listing shows which logical sections lie inside each given segment. For example, here we can see that the `INTERP` segment contains only the `.interp` section.
> The `.comment` section holds version control information,but doesn't map to any segment.

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

[Arm Assembly Internals and Reverse Engineering](https://www.amazon.com/Blue-Fox-Assembly-Internals-Analysis/dp/1119745306) | Chapter 2 ELF File Format Internals - ELF Program Headers:

The `INTERP` header is used to tell the operating system that an ELF file needs the help of another program to bring itself into memory. In almost all cases, this program will be the operating system loader file, which in this case is at the path `/lib/ld-linux-aarch64.so.1`.

When a program is executed, the operating system uses this header to load the supporting loader into memory and schedules the *`loader`*, rather than the program itself, as the *initial* target for execution. The use of an external loader is necessary if the program makes use of dynamically linked libraries. The external loader manages the program’s global symbol table, handles connecting binaries together in a process called *`relocation`*, and then eventually calls into the program’s entry point when it is ready.

Since this is the case for virtually all nontrivial programs except the loader itself, almost all programs will use this field to specify the system loader. The `INTERP` header is relevant only to program files themselves; for shared libraries loaded either during initial program load or dynamically during program execution, the value is ignored.

## Entry Point

The starting point of `a.out` can be seen in the output of `objdump -f` and `readelf -h`.

- `objdump -f a.out`: start address 0x0000000000000640
- `readelf -h a.out`: Entry point address: 0x640

We can use `addr2line` to resolve/translate the address to symbol:

```bash
$ addr2line -f -e a.out 0x640
_start
??:?
```

It turns out that symbol `_start` is at address 0x640, which is actually the entry point of the C program.

```bash
$ objdump --start-address=0x640 --stop-address=$((0x640+48)) -d a.out

a.out:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000640 <_start>:
 640:	d503201f 	nop
 644:	d280001d 	mov	x29, #0x0                   	// #0
 648:	d280001e 	mov	x30, #0x0                   	// #0
 64c:	aa0003e5 	mov	x5, x0
 650:	f94003e1 	ldr	x1, [sp]
 654:	910023e2 	add	x2, sp, #0x8
 658:	910003e6 	mov	x6, sp
 65c:	90000080 	adrp	x0, 10000 <__FRAME_END__+0xf770>
 660:	f947f800 	ldr	x0, [x0, #4080]
 664:	d2800003 	mov	x3, #0x0                   	// #0
 668:	d2800004 	mov	x4, #0x0                   	// #0
 66c:	97ffffe1 	bl	5f0 <__libc_start_main@plt>
```

As the collect2 options show, `_start` is actually provided by `/usr/lib/aarch64-linux-gnu/Scrt1.o`.

```bash title="objdump -d Scrt1.o"
$ objdump -d /usr/lib/aarch64-linux-gnu/Scrt1.o

/usr/lib/aarch64-linux-gnu/Scrt1.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <_start>:
   0:	d503201f 	nop
   4:	d280001d 	mov	x29, #0x0                   	// #0
   8:	d280001e 	mov	x30, #0x0                   	// #0
   c:	aa0003e5 	mov	x5, x0
  10:	f94003e1 	ldr	x1, [sp]
  14:	910023e2 	add	x2, sp, #0x8
  18:	910003e6 	mov	x6, sp
  1c:	90000000 	adrp	x0, 0 <main>
  20:	f9400000 	ldr	x0, [x0]
  24:	d2800003 	mov	x3, #0x0                   	// #0
  28:	d2800004 	mov	x4, #0x0                   	// #0
  2c:	94000000 	bl	0 <__libc_start_main>
  30:	94000000 	bl	0 <abort>
```

Although, by convention, C and C++ programs “begin” at the `main` function, programs do not actually begin execution here. Instead, they begin execution in a small stub of assembly code, traditionally at the symbol called `_start`. When linking against the standard C runtime, the `_start` function is usually a small stub of code that passes control to the *libc* helper function `__libc_start_main`. This function then prepares the parameters for the program’s `main` function and invokes it. The `main` function then runs the program’s core logic, and if main returns to `__libc_start_main`, the return value of `main` is then passed to `exit` to gracefully exit the program.

## gdb debug

Now just type `gdb a.out` to run the programme `a.out` with GDB. Here I'm using customised `gdb-pwndbg` instead of naked `gdb`, because I've installed the GDB Enhanced Extension [pwndbg](https://github.com/pwndbg/pwndbg).

> related post: [GDB manual & help](../toolchain/gdb/0-gdb-man-help.md) & [GDB Enhanced Extensions](../toolchain/gdb/7-gdb-enhanced.md).

After launched the GDB Console, type `entry` to start the debugged program stopping at its entrypoint address.

!!! note "difference between entry and starti"

    Note that the entrypoint may not be the first instruction executed by the program.
    If you want to stop on the first executed instruction, use the GDB's `starti` command.

It just stops at the entrypoint `_start` as expected:

```bash
$ gdb-pwndbg a.out
Reading symbols from a.out...
(No debugging symbols found in a.out)
pwndbg: loaded 157 pwndbg commands and 47 shell commands. Type pwndbg [--shell | --all] [filter] for a list.
pwndbg: created $rebase, $base, $ida GDB functions (can be used with print/break)
------- tip of the day (disable with set show-tips off) -------
Use the procinfo command for better process introspection (than the GDB's info proc command)
pwndbg> entry
Temporary breakpoint 1 at 0xaaaaaaaa0640
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".

Temporary breakpoint 1, 0x0000aaaaaaaa0640 in _start ()

────────────────────────────────────────[ BACKTRACE ]────────────────────────────────────────
 ► 0   0xaaaaaaaa0640 _start
─────────────────────────────────────────────────────────────────────────────────────────────
```

Then type `b main` to set a breakpoint at the `main()` function, then type `c` to continue.

- Or you can just type `until main` to run until main.

```bash
pwndbg> b main
Breakpoint 3 at 0xaaaaaaaa076c
pwndbg> c
Continuing.

Breakpoint 3, 0x0000aaaaaaaa076c in main ()

────────────────────────────────────────[ BACKTRACE ]────────────────────────────────────────
 ► 0   0xaaaaaaaa076c main+24
   1   0xfffff7e273fc __libc_start_call_main+108
   2   0xfffff7e274cc __libc_start_main+152
   3   0xaaaaaaaa0670 _start+48
─────────────────────────────────────────────────────────────────────────────────────────────
```

Look at the `BACKTRACE` context, it works as designed in `/usr/lib/aarch64-linux-gnu/Scrt1.o`.

Type `info [dll|sharedlibrary]` to show status of loaded shared object libraries.

```bash
pwndbg> info dll
From                To                  Syms Read   Shared Object Library
0x0000fffff7fc3c40  0x0000fffff7fe20a4  Yes         /lib/ld-linux-aarch64.so.1
0x0000fffff7e27040  0x0000fffff7f33090  Yes         /lib/aarch64-linux-gnu/libc.so.6
```

Everything is anticipated, under control.
