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
    Produce debugging information in the operating system's native format (stabs, COFF, XCOFF, or DWARF). GDB can work with this debugging information.

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
# -g defaults to -gdwarf = -gdwarf-5
$ cc helloc.c -o helloc -g
$ c++ hellocpp.cpp -o hellocpp -g
```

## Display debugging information

refer to [DWARF Debugging Format](../../elf/dwarf-debugging.md).

- `readelf -S` --section-headers : Display the sections' header
- `objdump -h`, --[section-]headers : Display the contents of the section headers

Common DWARF Debugging Sections:

- .debug_aranges
- .debug_info
- .debug_abbrev
- .debug_line
- .debug_str
- .debug_line_str

---

`Readelf` can display and decode the DWARF data in an object or executable file. The options are

The DWARF listing for all but the smallest programs is quite voluminous, so it would be a good idea to direct `readelf`'s output to a file and then browse the file with *less* or an editor such as *vi*.

```bash
-w - display all DWARF sections
-w[liaprmfFso] display specific sections -
    l - line table
    i - debug info
    a - abbreviation table
    p - public names
    r - ranges
    m - macro table
    f - debug frame (encoded)
    F - debug frame (decoded)
    s - string table
    o - location lists
```

`-wl`（--debug-dump=rawline）打印 .debug\_line section。

```bash
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

---

`objdump -W` 同 `readelf -w`。`-Wl`（--dwarf=rawline）打印 .debug\_line section。

```bash
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
