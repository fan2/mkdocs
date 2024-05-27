---
title: DWARF Debugging Format
authors:
    - xman
date:
    created: 2023-06-18T10:00:00
categories:
    - elf
comments: true
---

`DWARF` is a widely used, standardized debugging data format. It was originally designed along with Executable and Linkable Format (ELF).

<!-- more -->

[DWARF Debugging Information Format](https://dwarfstd.org/index.html)

- [DWARF Introduction](https://dwarfstd.org/doc/Debugging%20using%20DWARF-2012.pdf)
- [DWARF 3.0 Standard](https://dwarfstd.org/dwarf3std.html)
- [DWARF 4 Standard](https://dwarfstd.org/dwarf4std.html)
- [DWARF Version 5](https://dwarfstd.org/dwarf5std.html)

## DWARF Overview

[DWARF](https://en.wikipedia.org/wiki/DWARF) is a widely used, standardized debugging data format. DWARF was originally designed along with Executable and Linkable Format (ELF), although it is independent of object file formats. The name is a medieval fantasy complement to "ELF" that had no official meaning, although the name "Debugging With Arbitrary Record Formats" has since been proposed as a backronym.

DWARF originated with the C compiler and sdb debugger in Unix System V Release 4 (SVR4).

---

aadwarf64 - [DWARF for the Arm® 64-bit Architecture (AArch64)](https://github.com/ARM-software/abi-aa/blob/main/aadwarf64/aadwarf64.rst)

The ABI for the Arm 64-bit architecture specifies the use of DWARF 3.0 format debugging data. For details of the base standard see GDWARF.

The ABI for the Arm 64-bit architecture gives additional rules for how DWARF 3.0 should be used, and how it is extended in ways specific to the Arm 64-bit architecture. The following topics are covered in detail:

- The enumeration of DWARF register numbers for using in `.debug_frame` and `.debug_info` sections (DWARF register names).
- The definition of Canonical Frame Address (`CFA`) used by this ABI (Canonical frame address).
- The definition of Common Information Entries (`CIE`) used by this ABI (Common information entries).
- The definition of Call Frame Instructions (`CFI`) used by this ABI (Call frame instructions).
- The definition of DWARF Expression Operations used by this ABI (dwarf expression operations).

## Generating DWARF with GCC

It’s very simple to generate DWARF with `gcc`. Simply specify the `–g` option to generate debugging information. The ELF sections can be displayed using `objump` with the `–h` option.

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
$ cc test-gdb.c -o test-gdb -g
$ cc test-gdb.c -o test-gdb -gdwarf
$ cc test-gdb.c -o test-gdb -gdwarf-5
```

??? info "test-gdb.c"

    ```c linenums="1"
    #include <stdio.h>

    int func(int n)
    {
        int sum=0,i;
        for(i=0; i<n; i++)
        {
            sum+=i;
        }
        return sum;
    }

    int main(int argc, char* argv[])
    {
        int i;
        long result = 0;
        for(i=1; i<=100; i++)
        {
            result += i;
        }

        printf("result[1-100] = %ld\n", result );
        printf("result[1-250] = %d\n", func(250) );

        return 0;
    }
    ```

## dump DWARF information

`readelf -S` --section-headers : Display the sections' header
`objdump -h`, --[section-]headers : Display the contents of the section headers

Common DWARF Debugging Sections:

- .debug_aranges
- .debug_info
- .debug_abbrev
- .debug_line
- .debug_str
- .debug_line_str

### readelf -w

`Readelf` can display and decode the DWARF data in an object or executable file. The options are

The DWARF listing for all but the smallest programs is quite voluminous, so it would be a good idea to direct `readelf`'s output to a file and then browse the file with *less* or an editor such as *vi*.

`-w` / --debug-dump: Displays the contents of the DWARF debug sections in the file, if any are present.

```bash
$ readelf --help
  -w --debug-dump[a/=abbrev, A/=addr, r/=aranges, c/=cu_index, L/=decodedline,
                  f/=frames, F/=frames-interp, g/=gdb_index, i/=info, o/=loc,
                  m/=macro, p/=pubnames, t/=pubtypes, R/=Ranges, l/=rawline,
                  s/=str, O/=str-offsets, u/=trace_abbrev, T/=trace_aranges,
                  U/=trace_info]
                         Display the contents of DWARF debug sections
```

```bash
$ man readelf
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

```bash
pifan@rpi3b-ubuntu $ readelf -wl test-gdb
Raw dump of debug contents of section .debug_line:

  Offset:                      0x0
  Length:                      153
  DWARF Version:               5
  Address size (bytes):        8
  Segment selector (bytes):    0
  Prologue Length:             51
  Minimum Instruction Length:  4
  Maximum Ops per Instruction: 1
  Initial value of 'is_stmt':  1
  Line Base:                   -5
  Line Range:                  14
  Opcode Base:                 13

...
```

其他相关选项：`--dwarf-depth`, `--dwarf-start`

```bash
$ man readelf
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

```bash
$ man objdump

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

```bash
$ man objdump

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

```bash
pifan@rpi3b-ubuntu $ objdump -Wl test-gdb

test-gdb:     file format elf64-littleaarch64

Raw dump of debug contents of section .debug_line:

  Offset:                      0x0
  Length:                      153
  DWARF Version:               5
  Address size (bytes):        8
  Segment selector (bytes):    0
  Prologue Length:             51
  Minimum Instruction Length:  4
  Maximum Ops per Instruction: 1
  Initial value of 'is_stmt':  1
  Line Base:                   -5
  Line Range:                  14
  Opcode Base:                 13

...
```

#### misc

```bash
$ man objdump

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

## GAS CFI directives

[CFI directives (Using as)](https://sourceware.org/binutils/docs/as/CFI-directives.html)

[CFI support for GNU assembler (GAS)](https://www.logix.cz/michal/devel/gas-cfi/)

7.12.2 `.cfi_startproc [simple]`

- `.cfi_startproc` is used at the beginning of each function that should have an entry in `.eh_frame`. It initializes some internal data structures. Don’t forget to close the function by `.cfi_endproc`.

- Unless `.cfi_startproc` is used along with parameter simple it also emits some architecture dependent initial CFI instructions.

7.12.3 `.cfi_endproc`

- `.cfi_endproc` is used at the end of a function where it closes its unwind entry previously opened by `.cfi_startproc`, and emits it to `.eh_frame`.

7.12.11 `.cfi_def_cfa_offset offset`

- `.cfi_def_cfa_offset` modifies a rule for computing CFA. Register remains the same, but offset is new. Note that it is the absolute offset that will be added to a defined register to compute CFA address.

7.12.13 `.cfi_offset register, offset`

- Previous value of register is saved at offset *offset* from CFA.

7.12.17 `.cfi_restore register`

- `.cfi_restore` says that the rule for register is now the same as it was at the beginning of the function, after all initial instruction added by `.cfi_startproc` were executed.

[assembly - What are CFI directives in Gnu Assembler (GAS) used for? - Stack Overflow](https://stackoverflow.com/questions/2529185/what-are-cfi-directives-in-gnu-assembler-gas-used-for)

- [c++ - How to remove "noise" from GCC/clang assembly output? - Stack Overflow](https://stackoverflow.com/questions/38552116/how-to-remove-noise-from-gcc-clang-assembly-output)

To disable these, use the gcc option

```bash
-fno-asynchronous-unwind-tables
-fno-dwarf2-cfi-asm
```

I've got a feeling it stands for `Call Frame Information` and is a GNU AS extension to manage call frames. 

The CFI directives are used for debugging. It allows the debugger to unwind a stack. For example: if procedure A calls procedure B which then calls a common procedure C. Procedure C fails. You now want to know who actually called C and then you may want to know who called B.

A debugger can unwind this stack by using the stack pointer (%rsp) and register %rbp, however it needs to know how to find them. That is where the CFI directives come in.

```asm
movq %rsp, %rbp
.cfi_def_cfa_register 6
```

so the last line here tell it that the "Call frame address" is now in register 6 (%rbp)
