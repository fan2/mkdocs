---
title: GNU Binutils - readelf & objdump
authors:
    - xman
date:
    created: 2023-06-20T10:00:00
categories:
    - toolchain
    - elf
comments: true
---

`objdump` is the mother of all binary tools.
`readelf` subsumes the functionality of `size` and `nm`.
`objcopy` contains most of the functionality of `strip`.

<!-- more -->

[GNU Binary Utilities](https://en.wikipedia.org/wiki/GNU_Binary_Utilities) - [elfutils](https://sourceware.org/elfutils/)
[GNU Hurd](https://www.gnu.org/savannah-checkouts/gnu/hurd/binutils.html) / [GNU Binutils](https://www.gnu.org/software/binutils/) - @[sourceware](https://sourceware.org/binutils/) - [Documentation](https://sourceware.org/binutils/docs/)

- [readelf](https://man7.org/linux/man-pages/man1/readelf.1.html) - display information about ELF files
- [objdump](https://man7.org/linux/man-pages/man1/objdump.1.html) - display information from object files
- [strings](https://man7.org/linux/man-pages/man1/strings.1.html) - print the sequences of printable characters in files
- [nm](https://man7.org/linux/man-pages/man1/nm.1.html) - list symbols from object files
- [size](https://man7.org/linux/man-pages/man1/size.1.html) - list section sizes and total size of binary files
- [strip](https://man7.org/linux/man-pages/man1/strip.1.html) - discard symbols and other data from object files
- [objcopy](https://man7.org/linux/man-pages/man1/objcopy.1.html) - copy and translate object files

This article focuses on using GNU binutils to view and manipulate ELF files.

## headers

One way to view the architecture that an ELF binary is compiled to is via the `file` command.

The `readelf` command can display useful information about files in the ELF file format. It provides options to display ELF file header, program headers and section headers.

```bash
$ readelf --help

  -h --file-header       Display the ELF file header
  -l --program-headers   Display the program headers
     --segments          An alias for --program-headers
  -S --section-headers   Display the sections' header
     --sections          An alias for --section-headers
  -t --section-details   Display the section details. Implies -S.
  -e --headers           Equivalent to: -h -l -S

  -W --wide              Allow output width to exceed 80 characters
```

Meanwhile, `objdump` also provides equivalent options for displaying ELF header information.

```bash
$ objdump --help

  -a, --archive-headers    Display archive header information
  -f, --file-headers       Display the contents of the overall file header
  -h, --[section-]headers  Display the contents of the section headers
  -x, --all-headers        Display the contents of all headers

  -w, --wide                     Format output for more than 80 columns
```

## sections

Apart from `readelf -S` and `objdump -h`, we can use `size -Ax $ELF` to display a brief section size summary.

!!! note "section Type & Flags"

    Refer to [Section (Using as)](https://sourceware.org/binutils/docs/as/Section.html) for a knowledge of optional `Type` and `Flags` of ELF Version against the output of `readelf -S`.

    **Key to Flags**: W (write), A (alloc), X (execute), M (merge), S (strings), I (info), L (link order), O (extra OS processing required), G (group), T (TLS), C (compressed), x (unknown), o (OS specific), E (exclude), D (mbind), p (processor specific)

Pass `-p`/`-x` option to `readelf` can dump contents of specified section as strings/bytes.

- e.g. `readelf -x .text` or `readelf -p .rodata`

```bash
$ readelf --help

  -x --hex-dump=<number|name>
                         Dump the contents of section <number|name> as bytes
  -p --string-dump=<number|name>
                         Dump the contents of section <number|name> as strings
  -R --relocated-dump=<number|name>
                         Dump the relocated contents of section <number|name>

  -n --notes             Display the core notes (if present)
  -r --relocs            Display the relocations (if present)
  -u --unwind            Display the unwind info (if present)
  -d --dynamic           Display the dynamic section (if present)

  -V --version-info      Display the version sections (if present)
  -A --arch-specific     Display architecture specific information (if any)
```

For example, use `readelf -p` to dump string of sections:

```bash
$ readelf -p .comment test-gdb
$ readelf -p .interp test-gdb
$ readelf -p .strtab test-gdb
$ readelf -p .shstrtab test-gdb
```

Equivalently, use `objdump -j $section -s` or `objdump --seciont=$section` to display information for specified section.

```bash
$ objdump --help
  -j, --section=NAME       Only display information for section NAME

  -r, --reloc              Display the relocation entries in the file
  -R, --dynamic-reloc      Display the dynamic relocation entries in the file

  -s, --full-contents      Display the full contents of all sections requested
```

Use `objdump -j` to display the contents of specified sections:

```bash
$ objdump -j .comment -s test-gdb
$ objdump -j .interp -s test-gdb
```

## symbols

### syms

Type `readelf -s` to display the symbol table.

```bash
$ readelf --help

  -s --syms              Display the symbol table
     --symbols           An alias for --syms
     --dyn-syms          Display the dynamic symbol table
     --lto-syms          Display LTO symbol tables
     --sym-base=[0|8|10|16]
                         Force base for symbol sizes.  The options are
                         mixed (the default), octal, decimal, hexadecimal.
```

!!! note "read -s Type & Bind"

    Refer to [Type (Using as)](https://sourceware.org/binutils/docs/as/Type.html) for a knowledge of the *Type* column, such as `STT_FUNC`,`STT_OBJECT`,`STT_NOTYPE`,etc.
    Refer to [objdump](https://man7.org/linux/man-pages/man1/objdump.1.html) for a knowledge of the *Bind* column, such as `l`(`LOCAL`),`g`(`GLOBAL`),`w`(`WEAK`),etc.

The equivalent option for `objdump` is `-t`.

```bash
$ objdump --help

  -t, --syms               Display the contents of the symbol table(s)
  -T, --dynamic-syms       Display the contents of the dynamic symbol table
```

!!! note "objdump -t flags"

    Refer to [objdump](https://man7.org/linux/man-pages/man1/objdump.1.html) for a knowledge of the flag characters, such as `l`/`g`,`I`/`i`,`d`/`D`,`F`/`f`,etc.

### nm

List symbols in [file(s)] (a.out by default).

```bash
$ nm --help

  -D, --dynamic          Display dynamic symbols instead of normal symbols
      --defined-only     Display only defined symbols

  -g, --extern-only      Display only external symbols
    --ifunc-chars=CHARS  Characters to use when displaying ifunc symbols

  -l, --line-numbers     Use debugging information to find a filename and
                           line number for each symbol
  -n, --numeric-sort     Sort symbols numerically by address

  -r, --reverse-sort     Reverse the sense of the sort

  -S, --print-size       Print size of defined symbols

  -s, --print-armap      Include index for symbols from archive members
      --quiet            Suppress "no symbols" diagnostic
      --size-sort        Sort symbols by size
      --special-syms     Include special symbols in the output
      --synthetic        Display synthetic symbols as well

  -u, --undefined-only   Display only undefined symbols
```

!!! note "nm symbol type"

    Refer to [nm](https://man7.org/linux/man-pages/man1/nm.1.html) for a knowledge of the symbol type, such as `T`/`t`,`D`/`d`,`B`/`b`,`U`, etc.

## DWARF

[DWARF Introduction](https://dwarfstd.org/doc/Debugging%20using%20DWARF-2012.pdf): Debugging Information Entry (`DIE`)

- refer to related post: [DWARF Debugging Format](../elf/dwarf-debugging.md).

```bash
$ readelf --help

  -w --debug-dump[a/=abbrev, A/=addr, r/=aranges, c/=cu_index, L/=decodedline,
                  f/=frames, F/=frames-interp, g/=gdb_index, i/=info, o/=loc,
                  m/=macro, p/=pubnames, t/=pubtypes, R/=Ranges, l/=rawline,
                  s/=str, O/=str-offsets, u/=trace_abbrev, T/=trace_aranges,
                  U/=trace_info]

  --dwarf-depth=N        Do not display DIEs at depth N or greater
  --dwarf-start=N        Display DIEs starting at offset N
```

`readelf -w` is almost equivalent to `objdump -W`.

```bash
$ objdump --help

  -g, --debugging          Display debug information in object file
  -e, --debugging-tags     Display debug information using ctags style
  -G, --stabs              Display (in raw form) any STABS info in the file
  -W, --dwarf[a/=abbrev, A/=addr, r/=aranges, c/=cu_index, L/=decodedline,
              f/=frames, F/=frames-interp, g/=gdb_index, i/=info, o/=loc,
              m/=macro, p/=pubnames, t/=pubtypes, R/=Ranges, l/=rawline,
              s/=str, O/=str-offsets, u/=trace_abbrev, T/=trace_aranges,
              U/=trace_info]
                           Display the contents of DWARF debug sections
```

Both `readelf` and `objdump` support `--dwarf-depth` / `--dwarf-start` options.

```bash
$ man objdump

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

           If specified, this option will suppress printing of any
           header information and all DIEs before the DIE numbered n.
           Only siblings and children of the specified DIE will be
           printed.

           This can be used in conjunction with --dwarf-depth.
```

## CTF

[The CTF File Format](https://sourceware.org/binutils/docs/ctf-spec.html) - [Compact C Type Format](https://man.omnios.org/man5/ctf)

The `CTF` file format compactly describes C types and the association between function and data symbols and types: if embedded in ELF objects, it can exploit the ELF string table to reduce duplication further.

There are two major pieces to CTF: the *archive* and the *dictionary*. Some relatives and ancestors of CTF call dictionaries *containers*: the archive format is unique to this variant of CTF. (Much of the source code still uses the old term.)

[Binutils](https://www.gnu.org/software/binutils/)@[sourceware](https://sourceware.org/binutils/): libctf - A library for manipulating the CTF debug format.

[Ubuntu Manpage: ctfdump — dump the SUNW_ctf section of an ELF file](https://manpages.ubuntu.com/manpages/focal/en/man1/ctfdump.1.html)

```bash
$ readelf --help

  --ctf=<number|name>    Display CTF info from section <number|name>
  --ctf-parent=<name>    Use CTF archive member <name> as the CTF parent
  --ctf-symbols=<number|name>
                         Use section <number|name> as the CTF external symtab
  --ctf-strings=<number|name>
                         Use section <number|name> as the CTF external strtab
```

`objdump` provide equivalent options as `readelf` in dumping CTF info.

```bash
$ objdump --help

  -L, --process-links      Display the contents of non-debug sections in
                            separate debuginfo files.  (Implies -WK)
      --ctf[=SECTION]      Display CTF info from SECTION, (default `.ctf')
```

```bash
$ man objdump

       --ctf[=section]
           Display the contents of the specified CTF section.  CTF
           sections themselves contain many subsections, all of which
           are displayed in order.

           By default, display the name of the section named .ctf, which
           is the name emitted by ld.

       --ctf-parent=member
           If the CTF section contains ambiguously-defined types, it
           will consist of an archive of many CTF dictionaries, all
           inheriting from one dictionary containing unambiguous types.
           This member is by default named .ctf, like the section
           containing it, but it is possible to change this name using
           the "ctf_link_set_memb_name_changer" function at link time.
           When looking at CTF archives that have been created by a
           linker that uses the name changer to rename the parent
           archive member, --ctf-parent can be used to specify the name
           used for the parent.
```

## manipulate

[gcc - How to remove a specific ELF section, without stripping other symbols? - Stack Overflow](https://stackoverflow.com/questions/31453859/how-to-remove-a-specific-elf-section-without-stripping-other-symbols)

[Computer Systems - A Programmer’s Perspective](https://www.amazon.com/Computer-Systems-OHallaron-Randal-Bryant/dp/1292101768/) | Chapter 7: Linking - 7.14: Tools for Manipulating Object Files

```bash
$ man objdump

       --adjust-vma=offset
           When dumping information, first add offset to all the section
           addresses.  This is useful if the section addresses do not
           correspond to the symbol table, which can happen when putting
           sections at particular addresses when using a format which
           can not represent section addresses, such as a.out.
```

### strip

In embedded systems, resources are often limited. Sometimes in order to reduce the space occupied by program files (such as FLASH), we can remove debugging information from the program. The most commonly used tool is to use the `strip` tool to achieve this purpose. However, the same purpose can be achieved using `objcopy --strip-debug`.

```bash
$ strip --help

  -R --remove-section=<name>       Also remove section <name> from the output
     --remove-relocations <name>   Remove relocations from section <name>
  -s --strip-all                   Remove all symbol and relocation information
  -g -S -d --strip-debug           Remove all debugging symbols & sections
     --strip-dwo                   Remove all DWO sections
     --strip-unneeded              Remove all symbols not needed by relocations
     --only-keep-debug             Strip everything but the debug information

  -N --strip-symbol=<name>         Do not copy symbol <name>
     --keep-section=<name>         Do not strip section <name>
  -K --keep-symbol=<name>          Do not strip symbol <name>
     --keep-section-symbols        Do not strip section symbols
     --keep-file-symbols           Do not strip file symbol(s)
  -w --wildcard                    Permit wildcard in symbol comparison
  -x --discard-all                 Remove all non-global symbols
  -X --discard-locals              Remove any compiler-generated symbols
```

### objcopy

[Linux内核启动流程-基于ARM64](https://mshrimp.github.io/2020/04/19/Linux%E5%86%85%E6%A0%B8%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B-%E5%9F%BA%E4%BA%8EARM64/)

> vmlinux is a generated uncompressed pure kernel binary with all user-defined kernel components, but it is unable to boot the system. In order to load the Linux kernel image into memory and in an executable state, the kernel build system uses the `objcopy` command to clear unnecessary sections, compress vmlinux in ELF format, load and link through the bootloader, and finally generate a bootable binary zImage.

[简析Linux镜像生成过程: vmlinux->uImage](https://www.cnblogs.com/arnoldlu/p/14102272.html)

1. Generate `vmlinux` and `System.map` files by running `link-vmlinux.sh`.
2. Use `objcopy` to remove unnecessary segments in vmlinux and output binary format Image.
3. Compress the Image and output compressed files in different formats, such as `Image.gz` corresponding to gzip.
4. Add uboot header information to Image.gz to generate `uImage` file.

```bash
$ objcopy --help

  -j --only-section <name>         Only copy section <name> into the output
     --add-gnu-debuglink=<file>    Add section .gnu_debuglink linking to <file>
  -R --remove-section <name>       Remove section <name> from the output
     --remove-relocations <name>   Remove relocations from section <name>
  -S --strip-all                   Remove all symbol and relocation information
  -g --strip-debug                 Remove all debugging symbols & sections
     --strip-dwo                   Remove all DWO sections
     --strip-unneeded              Remove all symbols not needed by relocations

  -N --strip-symbol <name>         Do not copy symbol <name>

  -K --keep-symbol <name>          Do not strip symbol <name>

  -L --localize-symbol <name>      Force symbol <name> to be marked as a local
     --globalize-symbol <name>     Force symbol <name> to be marked as a global
  -G --keep-global-symbol <name>   Localize all symbols except <name>

  -x --discard-all                 Remove all non-global symbols
  -X --discard-locals              Remove any compiler-generated symbols
```

### BFD

[Binary File Descriptor library](https://en.wikipedia.org/wiki/Binary_File_Descriptor_library)

The Binary File Descriptor library (`BFD`) is the GNU Project's main mechanism for the portable *manipulation* of object files in a variety of formats. As of 2003, it supports approximately 50 file formats for some 25 instruction set architectures.

[bfd - GCC Wiki](https://gcc.gnu.org/wiki/bfd)

`BFD` is a package which allows applications to use the same routines to operate on object files whatever the object file format. A new object file format can be supported simply by creating a new BFD back end and adding it to the library.

BFD is split into two parts: the front end, and the back ends (one for each object file format).

1. The *front end* of BFD provides the interface to the user. It manages memory and various canonical data structures. The front end also decides which back end to use and when to call back end routines.
2. The *back ends* provide BFD its view of the real world. Each back end provides a set of calls which the BFD front end can use to maintain its canonical form. The back ends also may keep around information for their own use, for greater efficiency.

[GNU Manuals Online](https://www.gnu.org/manual/manual.en.html) - [BFD](https://sourceware.org/binutils/docs/bfd/)

1. [Overview](https://sourceware.org/binutils/docs/bfd/Overview.html)
2. [BFD front end](https://sourceware.org/binutils/docs/bfd/BFD-front-end.html)
3. [BFD back ends](https://sourceware.org/binutils/docs/bfd/BFD-back-ends.html)

[Binutils](https://www.gnu.org/software/binutils/)@[sourceware](https://sourceware.org/binutils/): [libbfd](https://sourceware.org/binutils/docs/bfd.pdf) - A library for manipulating binary files in a variety of different formats.

Using ld - [BFD](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_mono/ld.html#SEC30): You can use `objdump -i` to list all the formats available for your configuration.

```bash
$ objdump -i
BFD header file version (GNU Binutils for Ubuntu) 2.38

```

[binutils/bfd/bfd-in2.h](https://github.com/CyberGrandChallenge/binutils/blob/master/bfd/bfd-in2.h)

```c
/* BFD contains relocation entries. */
#define HAS_RELOC                   0x1

/* BFD is directly executable. */
#define EXEC_P                      0x2

/* BFD has symbols. */
#define HAS_SYMS                   0x10

/* BFD is a dynamic object. */
#define DYNAMIC                    0x40

/* BFD is dynamically paged (this is like an a.out ZMAGIC file) (the
linker sets this by default, but clears it for -r or -n or -N).  */
#define D_PAGED                   0x100
```

When you type `objdump -f` or `objdump -x` to display the contents of the overall/all file header(s), you'll see these Format_specific flags.

---

[Installing necessary packages to use libbfd library](https://askubuntu.com/questions/1385118/installing-necessary-packages-to-use-libbfd-binary-file-descriptor-library):

```bash
$ apt search binutils-dev
Sorting... Done
Full Text Search... Done
binutils-dev/jammy-updates,jammy-security 2.38-4ubuntu2.6 arm64
  GNU binary utilities (BFD development files)

$ sudo apt-get install binutils-dev

```

[Practical Binary Analysis](https://www.amazon.com/Practical-Binary-Analysis-Instrumentation-Disassembly/dp/1593279124) - Chapter 4: Building a Binary Loader Using libbfd
