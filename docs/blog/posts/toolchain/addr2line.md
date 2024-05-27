---
title: addr2line - resolve address to symbol
authors:
    - xman
date:
    created: 2023-06-22T10:00:00
categories:
    - toolchain
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

To tell GCC to emit extra information for use by a debugger, in almost all cases you need only to add `-g` to your other options.

```bash
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

## resolve crt entry

Dump section headers through `size -Ax`, `readelf -S` and `objdump -h`:

```bash
$ size -Ax test-gdb
test-gdb  :
section               size      addr

.init                 0x18     0x5b8

.text                0x1dc     0x640
.fini                 0x14     0x81c

$ readelf -S test-gdb
There are 34 section headers, starting at offset 0x20b0:

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align

  [11] .init             PROGBITS         00000000000005b8  000005b8
       0000000000000018  0000000000000000  AX       0     0     4

  [13] .text             PROGBITS         0000000000000640  00000640
       00000000000001dc  0000000000000000  AX       0     0     64
  [14] .fini             PROGBITS         000000000000081c  0000081c
       0000000000000014  0000000000000000  AX       0     0     4

$ objdump -h test-gdb

test-gdb:     file format elf64-littleaarch64

Sections:
Idx Name          Size      VMA               LMA               File off  Algn

 10 .init         00000018  00000000000005b8  00000000000005b8  000005b8  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE

 12 .text         000001dc  0000000000000640  0000000000000640  00000640  2**6
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 13 .fini         00000014  000000000000081c  000000000000081c  0000081c  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
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

!!! note "Ubuntu GCC 编译链接 C/C++"

    ubuntu 上编译链接 C 代码：dry-run: `gcc stdc.c -##`；compile: `gcc stdc.c -o c.out -v`。

    - gcc 依次调用 cc1->as->collect2，链接 Scrt1.o,crti.o,crtbeginS.o,`-lc`（[g]libc）,crtendS.o,crtn.o。

    ubuntu 上编译链接 C++ 代码：dry-run: `g++ stdcpp.cpp -##`；compile: `g++ stdcpp.cpp -o cpp.out -v`。

    - g++ 依次调用 cc1plus->as->collect2，链接 Scrt1.o,crti.o,crtbeginS.o,`-lstdc++`（libstdc++）,crtendS.o,crtn.o。

    **说明**：

    - gcc 的 `cc1` 已经集成了 [cpp](https://gcc.gnu.org/onlinedocs/cpp/Invocation.html) 预处理。
    - [collect2](https://gcc.gnu.org/onlinedocs/gccint/Collect2.html) 内部调用 *real* `ld` 完成最终的链接工作。
    - 关于 crt(C Runtime)，参考 [crtbegin.o vs. crtbeginS.o](https://stackoverflow.com/questions/22160888/what-is-the-difference-between-crtbegin-o-crtbegint-o-and-crtbegins-o) 和 [Mini FAQ about the misc libc/gcc crt files.](https://dev.gentoo.org/~vapier/crt.txt)。

Although, by convention, C and C++ programs “begin” at the `main` function, programs do not actually begin execution here. Instead, they begin execution in a small stub of assembly code, traditionally at the symbol called `_start`. When linking against the standard C runtime, the `_start` function is usually a small stub of code that passes control to the *libc* helper function `__libc_start_main`. This function then prepares the parameters for the program’s `main` function and invokes it. The `main` function then runs the program’s core logic, and if main returns to `__libc_start_main`, the return value of `main` is then passed to `exit` to gracefully exit the program.

`_start` is ususally defined `/usr/lib/aarch64-linux-gnu/crt1.o`:

```bash title="objdump -d crt1.o"
$ objdump -d /usr/lib/aarch64-linux-gnu/crt1.o

/usr/lib/aarch64-linux-gnu/crt1.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <_start>:
0:	d503201f 	nop
4:	d280001d 	mov	x29, #0x0                   	// #0
8:	d280001e 	mov	x30, #0x0                   	// #0
c:	aa0003e5 	mov	x5, x0
10:	f94003e1 	ldr	x1, [sp]
14:	910023e2 	add	x2, sp, #0x8
18:	910003e6 	mov	x6, sp
1c:	90000000 	adrp	x0, 0 <_start>
20:	91000000 	add	x0, x0, #0x0
24:	d2800003 	mov	x3, #0x0                   	// #0
28:	d2800004 	mov	x4, #0x0                   	// #0
2c:	94000000 	bl	0 <__libc_start_main>
30:	94000000 	bl	0 <abort>

0000000000000034 <__wrap_main>:
34:	d503201f 	nop
38:	14000000 	b	0 <main>
3c:	d503201f 	nop

0000000000000040 <_dl_relocate_static_pie>:
40:	d65f03c0 	ret
```

`_init` and `_fini` are defined in `/usr/lib/aarch64-linux-gnu/crti.o`:

```bash title="objdump -d crti.o"
$ objdump -d /usr/lib/aarch64-linux-gnu/crti.o

/usr/lib/aarch64-linux-gnu/crti.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <call_weak_fn>:
0:	90000000 	adrp	x0, 0 <__gmon_start__>
4:	f9400000 	ldr	x0, [x0]
8:	b4000040 	cbz	x0, 10 <call_weak_fn+0x10>
c:	14000000 	b	0 <__gmon_start__>
10:	d65f03c0 	ret

Disassembly of section .init:

0000000000000000 <_init>:
0:	d503201f 	nop
4:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
8:	910003fd 	mov	x29, sp
c:	94000000 	bl	0 <_init>

Disassembly of section .fini:

0000000000000000 <_fini>:
0:	d503201f 	nop
4:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
8:	910003fd 	mov	x29, sp
```

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
