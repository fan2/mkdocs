---
title: addr2line - resolve address
authors:
    - xman
date:
    created: 2023-06-22T10:00:00
categories:
    - elf
comments: true
---

[addr2line](https://man7.org/linux/man-pages/man1/addr2line.1.html) - convert addresses or symbol+offset into file names and line numbers.

<!-- more -->

```bash
addr2line --help
Usage: addr2line [option(s)] [addr(s)]
 Convert addresses into line number/file name pairs.
 If no addresses are specified on the command line, they will be read from stdin
 The options are:
  @<file>                Read options from <file>
  -a --addresses         Show addresses
  -b --target=<bfdname>  Set the binary file format
  -e --exe=<executable>  Set the input file name (default is a.out)
  -i --inlines           Unwind inlined functions
  -j --section=<name>    Read section-relative offsets instead of addresses
  -p --pretty-print      Make the output easier to read for humans
  -s --basenames         Strip directory names
  -f --functions         Show function names
  -C --demangle[=style]  Demangle function names
  -R --recurse-limit     Enable a limit on recursion whilst demangling.  [Default]
  -r --no-recurse-limit  Disable a limit on recursion whilst demangling
  -h --help              Display this information
  -v --version           Display the program's version

addr2line: supported targets: elf64-littleaarch64 elf64-bigaarch64 elf32-littleaarch64 elf32-bigaarch64 elf32-littlearm elf32-bigarm pei-aarch64-little elf64-little elf64-big elf32-little elf32-big srec symbolsrec verilog tekhex binary ihex plugin
```

Given an address or symbol+offset in an executable or an offset in a section of a relocatable object, it uses the debugging information to figure out which file name and line number are associated with it.

## demo program

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

To tell GCC to emit extra information for use by a debugger, in almost all cases you need only to add `-g` to your other options.

```bash
$ cc test-gdb.c -o test-gdb -g
$ cc test-gdb.c -o test-gdb -gdwarf
$ cc test-gdb.c -o test-gdb -gdwarf-5
```

??? info "test-gdb ELF header"

    ```bash
    $ file test-gdb
    test-gdb: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=65f667a433bbb8c27eeb9bab8db76816d07292dd, for GNU/Linux 3.7.0, with debug_info, not stripped

    $ objdump -f test-gdb

    test-gdb:     file format elf64-littleaarch64
    architecture: aarch64, flags 0x00000150:
    HAS_SYMS, DYNAMIC, D_PAGED
    start address 0x0000000000000640

    $ readelf -h test-gdb
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
      Start of section headers:          8368 (bytes into file)
      Flags:                             0x0
      Size of this header:               64 (bytes)
      Size of program headers:           56 (bytes)
      Number of program headers:         9
      Size of section headers:           64 (bytes)
      Number of section headers:         34
      Section header string table index: 33
    ```

## resolve crt entry

Dump section headers through `size -Ax`, `readelf -S` and `objdump -h`:

```bash
$ size -Ax test-gdb
test-gdb  :
section               size      addr

.init                 0x18     0x5b8

.text                0x1dc     0x640
.fini                 0x14     0x81c

$ readelf -SW test-gdb
There are 34 section headers, starting at offset 0x20b0:

Section Headers:
  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
  [ 1] .interp           PROGBITS        0000000000000238 000238 00001b 00   A  0   0  1

  [11] .init             PROGBITS        00000000000005b8 0005b8 000018 00  AX  0   0  4
  [12] .plt              PROGBITS        00000000000005d0 0005d0 000070 00  AX  0   0 16
  [13] .text             PROGBITS        0000000000000640 000640 0001dc 00  AX  0   0 64
  [14] .fini             PROGBITS        000000000000081c 00081c 000014 00  AX  0   0  4
  [15] .rodata           PROGBITS        0000000000000830 000830 000034 00   A  0   0  8

$ objdump -hw test-gdb

test-gdb:     file format elf64-littleaarch64

Sections:
Idx Name               Size      VMA               LMA               File off  Algn  Flags
  0 .interp            0000001b  0000000000000238  0000000000000238  00000238  2**0  CONTENTS, ALLOC, LOAD, READONLY, DATA

 10 .init              00000018  00000000000005b8  00000000000005b8  000005b8  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
 11 .plt               00000070  00000000000005d0  00000000000005d0  000005d0  2**4  CONTENTS, ALLOC, LOAD, READONLY, CODE
 12 .text              000001dc  0000000000000640  0000000000000640  00000640  2**6  CONTENTS, ALLOC, LOAD, READONLY, CODE
 13 .fini              00000014  000000000000081c  000000000000081c  0000081c  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
 14 .rodata            00000034  0000000000000830  0000000000000830  00000830  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
```

Then use `addr2line` to translate the `.init`, `.text` and `.fini` section entry:

```bash
$ addr2line -f -e test-gdb 0x5b8
_init
??:?

$ addr2line -f -e test-gdb 0x640
_start
??:?

$ addr2line -f -e test-gdb 0x81c
_fini
??:?
```

Symbol of `_start` is at address 0x640, which is actually the entry point of the C program:

```bash
$ readelf -h test-gdb

  Entry point address:               0x640

$ objdump -f test-gdb

start address 0x0000000000000640
```

[ELF Format Cheatsheet](https://gist.github.com/x0nu11byt3/bcb35c3de461e5fb66173071a2379779) | Sections, Common objects and functions:

- `_start`: This is where `e_entry` points to, and first code to be executed.
- `.init`: Executable code that performs initialization tasks and needs to run before any other code in the binary is executed (Then it has `SHF_EXECINSTR` flag) The system executes the code in the `.init` section *before* transferring control to the *`main`* entry point of the binary.
- `.fini`: The contrary as `.init`, it has executable code that must run *after* the *`main`* program completes.

## resolve a function

First type `readelf -wi` or `objdump -Wi` to take a look at the `.debug_info` section.

Here we only excerpt the subprogram `func` and its formal_parameter and local variable.

```bash
$ objdump -Wi test-gdb

test-gdb:     file format elf64-littleaarch64

Contents of the .debug_info section:

  Compilation Unit @ offset 0x0:
   Length:        0x134 (32-bit)
   Version:       5
   Unit Type:     DW_UT_compile (1)
   Abbrev Offset: 0x0
   Pointer Size:  8
 <0><c>: Abbrev Number: 5 (DW_TAG_compile_unit)
    <d>   DW_AT_producer    : (indirect string, offset: 0x12): GNU C17 11.4.0 -mlittle-endian -mabi=lp64 -g -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection
    <11>   DW_AT_language    : 29	(C11)
    <12>   DW_AT_name        : (indirect line string, offset: 0x19): test-gdb.c
    <16>   DW_AT_comp_dir    : (indirect line string, offset: 0x0): /home/pifan/Projects/cpp
    <1a>   DW_AT_low_pc      : 0x754
    <22>   DW_AT_high_pc     : 0xc8
    <2a>   DW_AT_stmt_list   : 0x0

 <1><f1>: Abbrev Number: 13 (DW_TAG_subprogram)
    <f2>   DW_AT_external    : 1
    <f2>   DW_AT_name        : (indirect string, offset: 0xd0): func
    <f6>   DW_AT_decl_file   : 1
    <f7>   DW_AT_decl_line   : 3
    <f8>   DW_AT_decl_column : 5
    <f9>   DW_AT_prototyped  : 1
    <f9>   DW_AT_type        : <0x35>
    <fd>   DW_AT_low_pc      : 0x754
    <105>   DW_AT_high_pc     : 0x4c
    <10d>   DW_AT_frame_base  : 1 byte block: 9c 	(DW_OP_call_frame_cfa)
    <10f>   DW_AT_call_all_calls: 1
 <2><10f>: Abbrev Number: 14 (DW_TAG_formal_parameter)
    <110>   DW_AT_name        : n
    <112>   DW_AT_decl_file   : 1
    <113>   DW_AT_decl_line   : 3
    <114>   DW_AT_decl_column : 14
    <115>   DW_AT_type        : <0x35>
    <119>   DW_AT_location    : 2 byte block: 91 6c 	(DW_OP_fbreg: -20)
 <2><11c>: Abbrev Number: 3 (DW_TAG_variable)
    <11d>   DW_AT_name        : sum
    <121>   DW_AT_decl_file   : 1
    <121>   DW_AT_decl_line   : 5
    <122>   DW_AT_decl_column : 9
    <123>   DW_AT_type        : <0x35>
    <127>   DW_AT_location    : 2 byte block: 91 78 	(DW_OP_fbreg: -8)
 <2><12a>: Abbrev Number: 3 (DW_TAG_variable)
    <12b>   DW_AT_name        : i
    <12d>   DW_AT_decl_file   : 1
    <12d>   DW_AT_decl_line   : 5
    <12e>   DW_AT_decl_column : 15
    <12f>   DW_AT_type        : <0x35>
    <133>   DW_AT_location    : 2 byte block: 91 7c 	(DW_OP_fbreg: -4)
```

On the other hand, type `nm`, `readelf -s` or `objdump -t` to display the symbol table.

```bash
$ nm test-gdb
[...snip...]
0000000000000754 T func
[...snip...]

$ readelf -s test-gdb
Symbol table '.symtab' contains 95 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 0000000000000238     0 SECTION LOCAL  DEFAULT    1 .interp

     [...snip...]

    85: 0000000000000754    76 FUNC    GLOBAL DEFAULT   13 func

$ objdump -t test-gdb

test-gdb:     file format elf64-littleaarch64

SYMBOL TABLE:
0000000000000238 l    d  .interp	0000000000000000              .interp

[...snip...]

0000000000000754 g     F .text	000000000000004c              func
```

Then use `addr2line -f` to convert the address 0x0000000000000754 into function name and corresponding line number/file name pairs.

```bash
$ addr2line -f -e test-gdb 0x0000000000000754
func
/home/pifan/Projects/cpp/test-gdb.c:4
```
