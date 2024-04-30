---
title: compiling for debugging with GDB
authors:
  - xman
date:
    created: 2020-02-04T10:00:00
categories:
    - toolchain
tags:
    - gcc
    - gdb
comments: true
---

[Compilation (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Compilation.html#Compilation)

In order to debug a program effectively, you need to generate debugging information when you compile it. This debugging information is stored in the object file; it describes the data type of each variable or function and the correspondence between source line numbers and addresses in the executable code.

To request debugging information, specify the `-g` option when you run the compiler.

<!-- more -->

## Produce debugging information

[Debugging Options (Using the GNU Compiler Collection (GCC))](https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html)

To tell GCC to emit extra information for use by a debugger, in almost all cases you need only to add `-g` to your other options.

```Shell
    -g
    Produce debugging information in the operating system’s native format (stabs, COFF, XCOFF, or DWARF). GDB can work with this debugging information.

    On most systems that use stabs format, -g enables use of extra debugging information that only GDB can use; this extra information makes debugging work better in GDB but probably makes other debuggers crash or refuse to read the program. If you want to control for certain whether to generate the extra information, use -gvms (see below).

    -ggdb
    Produce debugging information for use by GDB. This means to use the most expressive format available (DWARF, stabs, or the native format if neither of those are supported), including GDB extensions if at all possible.

    -gdwarf
    -gdwarf-version
    Produce debugging information in DWARF format (if that is supported). The value of version may be either 2, 3, 4 or 5; the default version for most targets is 5 (with the exception of VxWorks, TPF and Darwin / macOS, which default to version 2, and AIX, which defaults to version 4).

    Note that with DWARF Version 2, some ports require and always use some non-conflicting DWARF 3 extensions in the unwind tables.

    Version 4 may require GDB 7.0 and -fvar-tracking-assignments for maximum benefit. Version 5 requires GDB 8.0 or higher.

    GCC no longer supports DWARF Version 1, which is substantially different than Version 2 and later. For historical reasons, some other DWARF-related options such as -fno-dwarf2-cfi-asm) retain a reference to DWARF Version 2 in their names, but apply to all currently-supported versions of DWARF.
```

gcc 编译链接 C 代码，添加 `-g` 选项生成调试信息，才能够使用 GDB 进行调试。

```Shell
$ cc helloc.c -o helloc -g
$ c++ hellocpp.cpp -o hellocpp -g
```

## Display debugging information

### readelf -w

`-w` / --debug-dump: Displays the contents of the DWARF debug sections in the file, if any are present.

```Shell
           -w[lLiaprmfFsOoRtUuTgAckK]
           --debug-dump[=rawline,=decodedline,=info,=abbrev,=pubnames,=aranges,=macro,=frames,=frames-interp,=str,=str-offsets,=loc,=Ranges,=pubtypes,=trace_info,=trace_abbrev,=trace_aranges,=gdb_index,=addr,=cu_index,=links,=follow-links]
               Displays the contents of the DWARF debug sections in the
               file, if any are present.
               "l"
               "=rawline"
                   Displays the contents of the .debug_line section in a raw
                   format.

           "l"
           "=rawline"
               Displays the contents of the .debug_line section in a raw
               format.

           "L"
           "=decodedline"
               Displays the interpreted contents of the .debug_line
               section.
```

`-wl`（--debug-dump=rawline）打印 .debug\_line section。

```Shell
pifan@rpi4b-ubuntu $ readelf -wl helloc
Raw dump of debug contents of section .debug_line:

  Offset:                      0x0
  Length:                      78
  DWARF Version:               5
  Address size (bytes):        8
  Segment selector (bytes):    0
  Prologue Length:             42
  Minimum Instruction Length:  4
  Maximum Ops per Instruction: 1
  Initial value of 'is_stmt':  1
  Line Base:                   -5
  Line Range:                  14
  Opcode Base:                 13

...
```

其他相关选项：`--dwarf-depth`, `--dwarf-start`

```Shell
       --dwarf-depth=n
           Limit the dump of the ".debug_info" section to n children.
           This is only useful with --debug-dump=info.  The default is
           to print all DIEs; the special value 0 for n will also have
           this effect.

           With a non-zero value for n, DIEs at or deeper than n levels
           will not be printed.  The range for n is zero-based.

       --dwarf-start=n
           Print only DIEs beginning with the DIE numbered n.  This is
           only useful with --debug-dump=info.
```

### objdump

#### -g

```Shell
       -g
       --debugging
           Display debugging information.  This attempts to parse STABS
           debugging format information stored in the file and print it
           out using a C like syntax.  If no STABS debugging was found
           this option falls back on the -W option to print any DWARF
           information in the file.
```

#### -W

`objdump -W` 同 `readelf -w`。

```Shell
       -W[lLiaprmfFsoORtUuTgAckK]
       --dwarf[=rawline,=decodedline,=info,=abbrev,=pubnames,=aranges,=macro,=frames,=frames-interp,=str,=str-offsets,=loc,=Ranges,=pubtypes,=trace_info,=trace_abbrev,=trace_aranges,=gdb_index,=addr,=cu_index,=links,=follow-links]
           Displays the contents of the DWARF debug sections in the
           file, if any are present.

           "l"
           "=rawline"
               Displays the contents of the .debug_line section in a raw
               format.

           "L"
           "=decodedline"
               Displays the interpreted contents of the .debug_line
               section.
```

`-Wl`（--dwarf=rawline）打印 .debug\_line section。

```Shell
pifan@rpi4b-ubuntu $ objdump -Wl helloc

helloc:     file format elf64-littleaarch64

Raw dump of debug contents of section .debug_line:

  Offset:                      0x0
  Length:                      78
  DWARF Version:               5
  Address size (bytes):        8
  Segment selector (bytes):    0
  Prologue Length:             42
  Minimum Instruction Length:  4
  Maximum Ops per Instruction: 1
  Initial value of 'is_stmt':  1
  Line Base:                   -5
  Line Range:                  14
  Opcode Base:                 13

...
```

#### misc

```Shell
       -G
       --stabs
           Display the full contents of any sections requested.  Display
           the contents of the .stab and .stab.index and .stab.excl
           sections from an ELF file.  This is only useful on systems
           (such as Solaris 2.0) in which ".stab" debugging symbol-table
           entries are carried in an ELF section.  In most other file
           formats, debugging symbol-table entries are interleaved with
           linkage symbols, and are visible in the --syms output.
```
