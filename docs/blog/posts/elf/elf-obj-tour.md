---
title: REL ELF Walkthrough
authors:
    - xman
date:
    created: 2023-06-27T10:00:00
categories:
    - elf
comments: true
---

[Previously](./gcc-compilation-stage.md) we've compiled our C demo program with `gcc -c` command.

`gcc -c` compile or assemble the source files, but *do not link*. The linking stage simply is not done. The ultimate output is in the form of an object file for each source file.

In this article, I'll practice using [GNU binutils](./gnu-binutils.md) to take a close look at the `0701.o` product.

<!-- more -->

[Computer Systems - A Programmer's Perspective](https://www.amazon.com/Computer-Systems-OHallaron-Randal-Bryant/dp/1292101768/) | Chapter 7: Linking

- 7.3: Object Files
- 7.4: Relocatable Object Files

In the assembly phase, you finally get to generate some real *machine code*! The input of the assembly phase is the set of assembly language files generated in the compilation phase, and the output is a set of *object files*, sometimes also referred to as *modules*. Object files contain machine instructions that are in principle executable by the processor. You need to do some more work before you have a ready-torun binary executable file.

Typically, each source file corresponds to one assembly file, and each assembly file corresponds to one object file. To generate an object file, you can pass the `-c` flag to gcc.

The demo program is as follows.

```c title="0701.c"
/* Code 07-01, file name: 0701.c */
#include <stdio.h>
int main(int argc, char* argv[])
{
    printf("Hello, Linux!\n");
    return 0;
}
```

The command `cc 0701.c -c` can be broken down into two steps:

1. compile to assembly: `cc 0701.c -S [-o 0701.s]`
2. assemble to object: `as 0701.s -o 0701.o`

This option tells GCC to create the object file *without* invoking the linking process, so we can then run `objdump` on just our compiled code *without* seeing the disassembly of all the surrounding object files such as a C runtime.

## ELF header

related post: [ELF layout](./elf-layout.md).

Display the ELF file header:

```bash
$ file 0701.o
0701.o: ELF 64-bit LSB relocatable, ARM aarch64, version 1 (SYSV), not stripped

$ objdump -f 0701.o

0701.o:     file format elf64-littleaarch64
architecture: aarch64, flags 0x00000011:
HAS_RELOC, HAS_SYMS
start address 0x0000000000000000

$ readelf -h 0701.o
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              REL (Relocatable file)
  Machine:                           AArch64
  Version:                           0x1
  Entry point address:               0x0
  Start of program headers:          0 (bytes into file)
  Start of section headers:          784 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           0 (bytes)
  Number of program headers:         0
  Size of section headers:           64 (bytes)
  Number of section headers:         13
  Section header string table index: 12
```

Use [hexdump](../linux/shell/commands/linux-cmd-hexdump.md) to check the ELF Identification(e_ident[EI_NIDENT]) on the first 16 bytes in `Elf64_Ehdr`:

```bash
$ hd -n 16 0701.o
00000000  7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
00000010
```

e_type=`ET_REL`=0x0001, Relocatable file.

```bash
$ hexdump -s 16 -n 2 -e '"%07.7_ax " /2 "%04x " "\n"' 0701.o
0000010 0001
```

e_machine=`EM_AARCH64`=0xb7=183, ARM AARCH64.

```bash
$ hexdump -s 18 -n 2 -e '"%07.7_ax " /2 "%04x " "\n"' 0701.o
0000012 00b7
```

We can take this output and analyse it against the two previous results: [dynamic](./gcc-compilation-dynamic.md) & [static](./gcc-compilation-static.md).

At this stage, `readelf -h` shows that `0701.o`'s type is `REL` (*Relocatable* file), not yet executable, neither `DYN` pie nor integrated `EXEC`.

The output of `objdump -f` shows that the BFD format specific flags are `HAS_RELOC, HAS_SYMS`. The keyword is `HAS_RELOC`, which distinguishes between direct executable (`EXEC_P`) and PIE executable (`DYNAMIC`).

ELF type `relocatable` means that the file is marked as a relocatable piece of code or sometimes called an object file. Relocatable object files are generally pieces of Position independent code (PIC) that have not yet been linked into an executable. You will often see `.o` files in a compiled code base. These are the files that hold code and data suitable for creating an executable file.

No program headers exist in relocatable objects (ELF files of type `ET_REL`) because `.o` files are meant to be linked into an executable, but not meant to be loaded directly into memory; therefore, `readelf -l` will yield no results on `0701.o`.

```bash
$ readelf -lW 0701.o

There are no program headers in this file.
```

Linux loadable kernel modules are actually `ET_REL` objects and are an exception to the rule because they do get loaded directly into kernel memory and relocated on the fly.

## sections

`readelf [-S|--section-headers|--sections]`: Display the sections' header.

```bash
$ readelf -SW 0701.o
There are 13 section headers, starting at offset 0x310:

Section Headers:
  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        0000000000000000 000040 000028 00  AX  0   0  4
  [ 2] .rela.text        RELA            0000000000000000 000248 000048 18   I 10   1  8
  [ 3] .data             PROGBITS        0000000000000000 000068 000000 00  WA  0   0  1
  [ 4] .bss              NOBITS          0000000000000000 000068 000000 00  WA  0   0  1
  [ 5] .rodata           PROGBITS        0000000000000000 000068 00000e 00   A  0   0  8
  [ 6] .comment          PROGBITS        0000000000000000 000076 00002c 01  MS  0   0  1
  [ 7] .note.GNU-stack   PROGBITS        0000000000000000 0000a2 000000 00      0   0  1
  [ 8] .eh_frame         PROGBITS        0000000000000000 0000a8 000038 00   A  0   0  8
  [ 9] .rela.eh_frame    RELA            0000000000000000 000290 000018 18   I 10   8  8
  [10] .symtab           SYMTAB          0000000000000000 0000e0 000150 18     11  12  8
  [11] .strtab           STRTAB          0000000000000000 000230 000018 00      0   0  1
  [12] .shstrtab         STRTAB          0000000000000000 0002a8 000061 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), p (processor specific)
```

`objdump [-h|--section-headers|--headers]`: Display the contents of the section headers.

```bash
$ objdump -hw 0701.o

0701.o:     file format elf64-littleaarch64

Sections:
Idx Name            Size      VMA               LMA               File off  Algn  Flags
  0 .text           00000028  0000000000000000  0000000000000000  00000040  2**2  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data           00000000  0000000000000000  0000000000000000  00000068  2**0  CONTENTS, ALLOC, LOAD, DATA
  2 .bss            00000000  0000000000000000  0000000000000000  00000068  2**0  ALLOC
  3 .rodata         0000000e  0000000000000000  0000000000000000  00000068  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .comment        0000002c  0000000000000000  0000000000000000  00000076  2**0  CONTENTS, READONLY
  5 .note.GNU-stack 00000000  0000000000000000  0000000000000000  000000a2  2**0  CONTENTS, READONLY
  6 .eh_frame       00000038  0000000000000000  0000000000000000  000000a8  2**3  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA
```

`size`: Displays the sizes of sections inside binary files.

```bash
$ size -Ax 0701.o
0701.o  :
section           size   addr
.text             0x28    0x0
.data              0x0    0x0
.bss               0x0    0x0
.rodata            0xe    0x0
.comment          0x2c    0x0
.note.GNU-stack    0x0    0x0
.eh_frame         0x38    0x0
Total             0x9a
```

Compared to `objdump -h`, `readelf -S` outputs three more types of `RELA`, `SYMTAB` and `STRTAB`.

We can see that many of the sections we talked about are present, but there are also some that are not. If we compile `0701.o` into an executable, we will see that many new sections have been added, including 
`.interp`, `.dynsym`, `.plt`, `.dynamic`, `.got` and other sections that are related to dynamic linking and runtime relocations.

```bash
# dynamically linked, DYN (Position-Independent Executable file)
$ gcc 0701.o -o 0701.dyn

# dynamically linked, EXEC (Executable file)
$ ld /usr/lib/aarch64-linux-gnu/Scrt1.o /usr/lib/aarch64-linux-gnu/crti.o /usr/lib/gcc/aarch64-linux-gnu/11/crtbeginS.o 0701.o /usr/lib/aarch64-linux-gnu/libc.so /usr/lib/gcc/aarch64-linux-gnu/11/crtendS.o /usr/lib/aarch64-linux-gnu/crtn.o -o 0701.exe
```

## symbols

### symbol table

`readelf [-s|--syms|--symbols]`: Displays the entries in symbol table section of the file, if it has one.

- Refer to [Type (Using as)](https://sourceware.org/binutils/docs/as/Type.html) for a knowledge of the *Type* column, such as `STT_FUNC`,`STT_OBJECT`,`STT_NOTYPE`,etc.

```bash
$ readelf -s 0701.o

Symbol table '.symtab' contains 14 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS 0701.c
     2: 0000000000000000     0 SECTION LOCAL  DEFAULT    1 .text
     3: 0000000000000000     0 SECTION LOCAL  DEFAULT    3 .data
     4: 0000000000000000     0 SECTION LOCAL  DEFAULT    4 .bss
     5: 0000000000000000     0 SECTION LOCAL  DEFAULT    5 .rodata
     6: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT    5 $d
     7: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT    1 $x
     8: 0000000000000000     0 SECTION LOCAL  DEFAULT    7 .note.GNU-stack
     9: 0000000000000014     0 NOTYPE  LOCAL  DEFAULT    8 $d
    10: 0000000000000000     0 SECTION LOCAL  DEFAULT    8 .eh_frame
    11: 0000000000000000     0 SECTION LOCAL  DEFAULT    6 .comment
    12: 0000000000000000    40 FUNC    GLOBAL DEFAULT    1 main
    13: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND puts
```

[objdump [-t|--syms]](https://man7.org/linux/man-pages/man1/objdump.1.html): Print the symbol table entries of the file.

1. `l`/`g`: local, global
2. `d`: debugging symbol
3. `df`: debugging symbol - file
4. `F`: function
5. `UND`: undefined

```bash
$ objdump -t 0701.o

0701.o:     file format elf64-littleaarch64

SYMBOL TABLE:
0000000000000000 l    df *ABS*	0000000000000000 0701.c
0000000000000000 l    d  .text	0000000000000000 .text
0000000000000000 l    d  .data	0000000000000000 .data
0000000000000000 l    d  .bss	0000000000000000 .bss
0000000000000000 l    d  .rodata	0000000000000000 .rodata
0000000000000000 l    d  .note.GNU-stack	0000000000000000 .note.GNU-stack
0000000000000000 l    d  .eh_frame	0000000000000000 .eh_frame
0000000000000000 l    d  .comment	0000000000000000 .comment
0000000000000000 g     F .text	0000000000000028 main
0000000000000000         *UND*	0000000000000000 puts
```

### List symbols

List symbols in 0701.o:

> Refer to [nm](https://man7.org/linux/man-pages/man1/nm.1.html) for a knowledge of the symbol type, such as `T`/`t`,`D`/`d`,`B`/`b`,`U`, etc.

1. `T`: The symbol is in the text (code) section, uppercase means global (external).
2. `U`: The symbol is undefined.

```bash
$ nm 0701.o
0000000000000000 T main
                 U puts
```

Print size of defined symbols:

```bash
$ nm -S 0701.o
0000000000000000 0000000000000028 T main
                 U puts
```

Display only external(global) symbols:

```bash
$ nm -g 0701.o
0000000000000000 T main
                 U puts
```

Display only defined/undefined symbols:

```bash
$ nm --defined-only 0701.o
0000000000000000 T main

$ nm -u 0701.o
                 U puts
```

## disassemble

related post: [objdump --disassemble](./objdump-d.md).

`gcc -c` tells GCC to create the object file without invoking the linking process, so we can then run `objdump` on just our compiled code *without* seeing the disassembly of all the surrounding object files such as a C runtime.

### objdump -d

`objdump [-d|--disassemble[=symbol]]`: Display the assembler mnemonics for the machine instructions from the input file.

Display assembler contents of executable sections, here is the `.text` section:

```bash
$ objdump -d 0701.o

0701.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <main>:
   0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   4:	910003fd 	mov	x29, sp
   8:	b9001fe0 	str	w0, [sp, #28]
   c:	f9000be1 	str	x1, [sp, #16]
  10:	90000000 	adrp	x0, 0 <main>
  14:	91000000 	add	x0, x0, #0x0
  18:	94000000 	bl	0 <puts>
  1c:	52800000 	mov	w0, #0x0                   	// #0
  20:	a8c27bfd 	ldp	x29, x30, [sp], #32
  24:	d65f03c0 	ret
```

### objdump -S

Intermix source code with disassembly.

- `objdump [-S|--source]`: Display source code intermixed with disassembly, if possible. Implies `-d`.
- `[--source-comment[=text]]` : Like the `-S` option, but all source code lines are displayed with a prefix of txt(defaults to `#`).

It needs the debugging information to find out which filename and line number are associated with the corresponding assembly/instructions.

To tell GCC to emit extra information for use by a debugger, in almost all cases you need only to add `-g` to your other options.

```bash
$ cc 0701.c -c -g
$ cc 0701.c -c -gdwarf
$ cc 0701.c -c -gdwarf-5
$ cc 0701.c -c -g -o 0701.go
```

This following comprehensive example demonstrates disassembling the specified symbol/function with a mix of source code comment markers and line numbers.

```bash
$ objdump --source-comment -l 0701.go

0701.go:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <main>:
main():
/home/pifan/Projects/cpp/0701.c:4
# /* Code 07-01, file name: 0701.c */
# #include <stdio.h>
# int main(int argc, char* argv[])
# {
   0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   4:	910003fd 	mov	x29, sp
   8:	b9001fe0 	str	w0, [sp, #28]
   c:	f9000be1 	str	x1, [sp, #16]
/home/pifan/Projects/cpp/0701.c:5
#     printf("Hello, Linux!\n");
  10:	90000000 	adrp	x0, 0 <main>
  14:	91000000 	add	x0, x0, #0x0
  18:	94000000 	bl	0 <puts>
/home/pifan/Projects/cpp/0701.c:6
#     return 0;
  1c:	52800000 	mov	w0, #0x0                   	// #0
/home/pifan/Projects/cpp/0701.c:7
# }
  20:	a8c27bfd 	ldp	x29, x30, [sp], #32
  24:	d65f03c0 	ret
```
