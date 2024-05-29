---
title: objdump --disassemble
authors:
    - xman
date:
    created: 2023-06-24T10:00:00
categories:
    - elf
comments: true
---

[objdump](https://man7.org/linux/man-pages/man1/objdump.1.html) - display information from object files.
`objdump -d`: Display the assembler mnemonics for the machine instructions from the input file.

<!-- more -->

## help tour

We can invoke `objdump -d $OBJ_FILE` or `objdump -d $ELF_FILE` to disassemble object file or ELF file.

```bash
$ objdump --help

  -d, --disassemble        Display assembler contents of executable sections
  -D, --disassemble-all    Display assembler contents of all sections
      --disassemble=<sym>  Display assembler contents from <sym>
  -S, --source             Intermix source code with disassembly
      --source-comment[=<txt>] Prefix lines of source code with <txt>

  -l, --line-numbers             Include line numbers and filenames in output
  -F, --file-offsets             Include file offsets when displaying information
```

Option `--disassemble=<sym>` can be used to disassemble specified symbol(function).

Moreover, we can specify a disassemble range through `--start-address` and `--stop-address`.

```bash
$ man objdump

       --start-address=address
           Start displaying data at the specified address.  This affects
           the output of the -d, -r and -s options.

       --stop-address=address
           Stop displaying data at the specified address.  This affects
           the output of the -d, -r and -s options.
```

The `-M` option gives us chance to specify some disassembler options.

```bash
$ objdump --help

  -M, --disassembler-options=OPT Pass text OPT on to the disassembler

$ man objdump

       -M options
       --disassembler-options=options

           For the x86, some of the options duplicate functions of the
           -m switch, but allow finer grained control.

           "intel"
           "att"
               Select between intel syntax mode and AT&T syntax mode.

           "intel-mnemonic"
           "att-mnemonic"
               Select between intel mnemonic mode and AT&T mnemonic
               mode.  Note: "intel-mnemonic" implies "intel" and
               "att-mnemonic" implies "att".
```

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

## disassemble

The option `-d|--disassemble` only disassembles those sections which are expected to contain instructions(executable sections).

- `-D|--disassemble-all`: disassemble the contents of all non-empty non- bss sections, not just those expected to contain instructions.

For [gcc-aarch64-linux-gnu](../toolchain/arm-toolchain.md), the CRT object /usr/lib/aarch64-linux-gnu/**`crti.o`**|**`crtn.o`** defines the function *prologs*/*epilogs* for the `.init`/`.fini` sections.

Let's type `objdump -d` to check it out and get under the hood.

```bash title="disas crti.o/crtn.o"
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

$ objdump -d /usr/lib/aarch64-linux-gnu/crtn.o

/usr/lib/aarch64-linux-gnu/crtn.o:     file format elf64-littleaarch64


Disassembly of section .init:

0000000000000000 <.init>:
   0:	a8c17bfd 	ldp	x29, x30, [sp], #16
   4:	d65f03c0 	ret

Disassembly of section .fini:

0000000000000000 <.fini>:
   0:	a8c17bfd 	ldp	x29, x30, [sp], #16
   4:	d65f03c0 	ret
```

Get back to the point, let's continue to disassemble the entire demo program.

It's really kind of long, but we always have deja vu. Trust your instinct!

The first and last sections `.init` and `.fini` are simply copied from `crti.o`.

??? info "objdump -d test-gdb"

    ```bash linenums="1"
    $ objdump -d test-gdb

    test-gdb:     file format elf64-littleaarch64


    Disassembly of section .init:

    00000000000005b8 <_init>:
    5b8:	d503201f 	nop
    5bc:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    5c0:	910003fd 	mov	x29, sp
    5c4:	9400002c 	bl	674 <call_weak_fn>
    5c8:	a8c17bfd 	ldp	x29, x30, [sp], #16
    5cc:	d65f03c0 	ret

    Disassembly of section .plt:

    00000000000005d0 <.plt>:
    5d0:	a9bf7bf0 	stp	x16, x30, [sp, #-16]!
    5d4:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf698>
    5d8:	f947d211 	ldr	x17, [x16, #4000]
    5dc:	913e8210 	add	x16, x16, #0xfa0
    5e0:	d61f0220 	br	x17
    5e4:	d503201f 	nop
    5e8:	d503201f 	nop
    5ec:	d503201f 	nop

    00000000000005f0 <__libc_start_main@plt>:
    5f0:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf698>
    5f4:	f947d611 	ldr	x17, [x16, #4008]
    5f8:	913ea210 	add	x16, x16, #0xfa8
    5fc:	d61f0220 	br	x17

    0000000000000600 <__cxa_finalize@plt>:
    600:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf698>
    604:	f947da11 	ldr	x17, [x16, #4016]
    608:	913ec210 	add	x16, x16, #0xfb0
    60c:	d61f0220 	br	x17

    0000000000000610 <__gmon_start__@plt>:
    610:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf698>
    614:	f947de11 	ldr	x17, [x16, #4024]
    618:	913ee210 	add	x16, x16, #0xfb8
    61c:	d61f0220 	br	x17

    0000000000000620 <abort@plt>:
    620:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf698>
    624:	f947e211 	ldr	x17, [x16, #4032]
    628:	913f0210 	add	x16, x16, #0xfc0
    62c:	d61f0220 	br	x17

    0000000000000630 <printf@plt>:
    630:	90000090 	adrp	x16, 10000 <__FRAME_END__+0xf698>
    634:	f947e611 	ldr	x17, [x16, #4040]
    638:	913f2210 	add	x16, x16, #0xfc8
    63c:	d61f0220 	br	x17

    Disassembly of section .text:

    0000000000000640 <_start>:
    640:	d503201f 	nop
    644:	d280001d 	mov	x29, #0x0                   	// #0
    648:	d280001e 	mov	x30, #0x0                   	// #0
    64c:	aa0003e5 	mov	x5, x0
    650:	f94003e1 	ldr	x1, [sp]
    654:	910023e2 	add	x2, sp, #0x8
    658:	910003e6 	mov	x6, sp
    65c:	90000080 	adrp	x0, 10000 <__FRAME_END__+0xf698>
    660:	f947f800 	ldr	x0, [x0, #4080]
    664:	d2800003 	mov	x3, #0x0                   	// #0
    668:	d2800004 	mov	x4, #0x0                   	// #0
    66c:	97ffffe1 	bl	5f0 <__libc_start_main@plt>
    670:	97ffffec 	bl	620 <abort@plt>

    0000000000000674 <call_weak_fn>:
    674:	90000080 	adrp	x0, 10000 <__FRAME_END__+0xf698>
    678:	f947f400 	ldr	x0, [x0, #4072]
    67c:	b4000040 	cbz	x0, 684 <call_weak_fn+0x10>
    680:	17ffffe4 	b	610 <__gmon_start__@plt>
    684:	d65f03c0 	ret
    688:	d503201f 	nop
    68c:	d503201f 	nop

    0000000000000690 <deregister_tm_clones>:
    690:	b0000080 	adrp	x0, 11000 <__data_start>
    694:	91004000 	add	x0, x0, #0x10
    698:	b0000081 	adrp	x1, 11000 <__data_start>
    69c:	91004021 	add	x1, x1, #0x10
    6a0:	eb00003f 	cmp	x1, x0
    6a4:	540000c0 	b.eq	6bc <deregister_tm_clones+0x2c>  // b.none
    6a8:	90000081 	adrp	x1, 10000 <__FRAME_END__+0xf698>
    6ac:	f947ec21 	ldr	x1, [x1, #4056]
    6b0:	b4000061 	cbz	x1, 6bc <deregister_tm_clones+0x2c>
    6b4:	aa0103f0 	mov	x16, x1
    6b8:	d61f0200 	br	x16
    6bc:	d65f03c0 	ret

    00000000000006c0 <register_tm_clones>:
    6c0:	b0000080 	adrp	x0, 11000 <__data_start>
    6c4:	91004000 	add	x0, x0, #0x10
    6c8:	b0000081 	adrp	x1, 11000 <__data_start>
    6cc:	91004021 	add	x1, x1, #0x10
    6d0:	cb000021 	sub	x1, x1, x0
    6d4:	d37ffc22 	lsr	x2, x1, #63
    6d8:	8b810c41 	add	x1, x2, x1, asr #3
    6dc:	9341fc21 	asr	x1, x1, #1
    6e0:	b40000c1 	cbz	x1, 6f8 <register_tm_clones+0x38>
    6e4:	90000082 	adrp	x2, 10000 <__FRAME_END__+0xf698>
    6e8:	f947fc42 	ldr	x2, [x2, #4088]
    6ec:	b4000062 	cbz	x2, 6f8 <register_tm_clones+0x38>
    6f0:	aa0203f0 	mov	x16, x2
    6f4:	d61f0200 	br	x16
    6f8:	d65f03c0 	ret
    6fc:	d503201f 	nop

    0000000000000700 <__do_global_dtors_aux>:
    700:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
    704:	910003fd 	mov	x29, sp
    708:	f9000bf3 	str	x19, [sp, #16]
    70c:	b0000093 	adrp	x19, 11000 <__data_start>
    710:	39404260 	ldrb	w0, [x19, #16]
    714:	35000140 	cbnz	w0, 73c <__do_global_dtors_aux+0x3c>
    718:	90000080 	adrp	x0, 10000 <__FRAME_END__+0xf698>
    71c:	f947f000 	ldr	x0, [x0, #4064]
    720:	b4000080 	cbz	x0, 730 <__do_global_dtors_aux+0x30>
    724:	b0000080 	adrp	x0, 11000 <__data_start>
    728:	f9400400 	ldr	x0, [x0, #8]
    72c:	97ffffb5 	bl	600 <__cxa_finalize@plt>
    730:	97ffffd8 	bl	690 <deregister_tm_clones>
    734:	52800020 	mov	w0, #0x1                   	// #1
    738:	39004260 	strb	w0, [x19, #16]
    73c:	f9400bf3 	ldr	x19, [sp, #16]
    740:	a8c27bfd 	ldp	x29, x30, [sp], #32
    744:	d65f03c0 	ret
    748:	d503201f 	nop
    74c:	d503201f 	nop

    0000000000000750 <frame_dummy>:
    750:	17ffffdc 	b	6c0 <register_tm_clones>

    0000000000000754 <func>:
    754:	d10083ff 	sub	sp, sp, #0x20
    758:	b9000fe0 	str	w0, [sp, #12]
    75c:	b9001bff 	str	wzr, [sp, #24]
    760:	b9001fff 	str	wzr, [sp, #28]
    764:	14000008 	b	784 <func+0x30>
    768:	b9401be1 	ldr	w1, [sp, #24]
    76c:	b9401fe0 	ldr	w0, [sp, #28]
    770:	0b000020 	add	w0, w1, w0
    774:	b9001be0 	str	w0, [sp, #24]
    778:	b9401fe0 	ldr	w0, [sp, #28]
    77c:	11000400 	add	w0, w0, #0x1
    780:	b9001fe0 	str	w0, [sp, #28]
    784:	b9401fe1 	ldr	w1, [sp, #28]
    788:	b9400fe0 	ldr	w0, [sp, #12]
    78c:	6b00003f 	cmp	w1, w0
    790:	54fffecb 	b.lt	768 <func+0x14>  // b.tstop
    794:	b9401be0 	ldr	w0, [sp, #24]
    798:	910083ff 	add	sp, sp, #0x20
    79c:	d65f03c0 	ret

    00000000000007a0 <main>:
    7a0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
    7a4:	910003fd 	mov	x29, sp
    7a8:	b9001fe0 	str	w0, [sp, #28]
    7ac:	f9000be1 	str	x1, [sp, #16]
    7b0:	f90017ff 	str	xzr, [sp, #40]
    7b4:	52800020 	mov	w0, #0x1                   	// #1
    7b8:	b90027e0 	str	w0, [sp, #36]
    7bc:	14000008 	b	7dc <main+0x3c>
    7c0:	b98027e0 	ldrsw	x0, [sp, #36]
    7c4:	f94017e1 	ldr	x1, [sp, #40]
    7c8:	8b000020 	add	x0, x1, x0
    7cc:	f90017e0 	str	x0, [sp, #40]
    7d0:	b94027e0 	ldr	w0, [sp, #36]
    7d4:	11000400 	add	w0, w0, #0x1
    7d8:	b90027e0 	str	w0, [sp, #36]
    7dc:	b94027e0 	ldr	w0, [sp, #36]
    7e0:	7101901f 	cmp	w0, #0x64
    7e4:	54fffeed 	b.le	7c0 <main+0x20>
    7e8:	f94017e1 	ldr	x1, [sp, #40]
    7ec:	90000000 	adrp	x0, 0 <__abi_tag-0x278>
    7f0:	9120e000 	add	x0, x0, #0x838
    7f4:	97ffff8f 	bl	630 <printf@plt>
    7f8:	52801f40 	mov	w0, #0xfa                  	// #250
    7fc:	97ffffd6 	bl	754 <func>
    800:	2a0003e1 	mov	w1, w0
    804:	90000000 	adrp	x0, 0 <__abi_tag-0x278>
    808:	91214000 	add	x0, x0, #0x850
    80c:	97ffff89 	bl	630 <printf@plt>
    810:	52800000 	mov	w0, #0x0                   	// #0
    814:	a8c37bfd 	ldp	x29, x30, [sp], #48
    818:	d65f03c0 	ret

    Disassembly of section .fini:

    000000000000081c <_fini>:
    81c:	d503201f 	nop
    820:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    824:	910003fd 	mov	x29, sp
    828:	a8c17bfd 	ldp	x29, x30, [sp], #16
    82c:	d65f03c0 	ret
    ```

## disassemble section

Last time, in [addr2line - resolve address](./addr2line.md), we've used `addr2line` to resolve the first symbol resided in the entry of a section, such as `.init` and `.fini`.

Specifying `-j $section` to `objdump -d` would disassemble selected sections. So we can simply type `objdump -d -j $section` to disassemble the entire section.

```bash
$ objdump -j .init -d test-gdb

$ objdump -j .fini -d test-gdb

```

By convention, the machine-code instructions generated by the compiler will all be placed in the `.text` section of the program binary. This means that the `.text` section holds the executable instructions of a program.

Now, let's disassemble the main section `.text`.

```bash
# display full contents of the .text section
$ objdump -j .text -s test-gdb

# disassemble contents of the .text section
$ objdump -j .text -d test-gdb

test-gdb:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000640 <_start>:

[...snip...]

0000000000000674 <call_weak_fn>:

[...snip...]

0000000000000690 <deregister_tm_clones>:

[...snip...]

00000000000006c0 <register_tm_clones>:

[...snip...]

0000000000000700 <__do_global_dtors_aux>:

[...snip...]

0000000000000750 <frame_dummy>:
 750:	17ffffdc 	b	6c0 <register_tm_clones>

0000000000000754 <func>:

[...snip...]

00000000000007a0 <main>:

[...snip...]

```

Please refer to [ELF Format Cheatsheet | Common objects and functions](https://gist.github.com/x0nu11byt3/bcb35c3de461e5fb66173071a2379779) to get some knowledge of `_start`, `register_tm_clones`/`deregister_tm_clones`, `frame_dummy`, etc.

Another example, show contents of section `.init_array` and its disassembly.

```bash
$ objdump -j .init_array -s test-gdb

test-gdb:     file format elf64-littleaarch64

Contents of section .init_array:
 10d90 50070000 00000000                    P.......

$ objdump -j .init_array -d test-gdb

test-gdb:     file format elf64-littleaarch64


Disassembly of section .init_array:

0000000000010d90 <__frame_dummy_init_array_entry>:
   10d90:	50 07 00 00 00 00 00 00                             P.......
```

Try to disassemble section `.init_array`, it's interpreted as nonsense `udf`(undefined instruction).

```bash
$ objdump -j .init_array -D test-gdb

test-gdb:     file format elf64-littleaarch64


Disassembly of section .init_array:

0000000000010d90 <__frame_dummy_init_array_entry>:
   10d90:	00000750 	udf	#1872
   10d94:	00000000 	udf	#0
```

## disassemble sym/func

The option `-d|--disassemble[=symbol]` only disassembles those sections which are expected to contain instructions(executable sections).

If the optional *symbol* argument is given, then display the assembler mnemonics starting at *symbol*. If symbol is a function name then disassembly will stop at the end of the function, otherwise it will stop when the next symbol is encountered.

Disassemble `main` function:

> For the full results, see output of `objdump -d test-gdb` above: line 162\~193, [0x7a0, 0x818]

```bash
$ objdump --disassemble=main test-gdb

test-gdb:     file format elf64-littleaarch64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000000007a0 <main>:
 7a0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
 7a4:	910003fd 	mov	x29, sp

 [7a8...snip...808]

 80c:	97ffff89 	bl	630 <printf@plt>
 810:	52800000 	mov	w0, #0x0                   	// #0
 814:	a8c37bfd 	ldp	x29, x30, [sp], #48
 818:	d65f03c0 	ret

Disassembly of section .fini:
```

Disassemble subroutine `func`:

> For the full results, see output of `objdump -d test-gdb` above: line 141\~160, [0x754, 0x79c]

```bash
$ objdump --disassemble=func test-gdb

test-gdb:     file format elf64-littleaarch64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000000754 <func>:
 754:	d10083ff 	sub	sp, sp, #0x20

 758:	b9000fe0 	str	w0, [sp, #12]

 [75c...snip...790]

 794:	b9401be0 	ldr	w0, [sp, #24]
 798:	910083ff 	add	sp, sp, #0x20
 79c:	d65f03c0 	ret

Disassembly of section .fini:
```

## disassemble addr range

### disas section

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

As you can see from the output above, the `.init` section starts at 0x5b8 with size 0x18, ends at 0x5d0.

Use the following command to disassemble the addressed range [start, end).

```bash
$ objdump -d --start-address=0x5b8 --stop-address=0x5d0 test-gdb

test-gdb:     file format elf64-littleaarch64


Disassembly of section .init:

00000000000005b8 <_init>:
 5b8:	d503201f 	nop
 5bc:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
 5c0:	910003fd 	mov	x29, sp
 5c4:	9400002c 	bl	674 <call_weak_fn>
 5c8:	a8c17bfd 	ldp	x29, x30, [sp], #16
 5cc:	d65f03c0 	ret
```

It's equivalent to `objdump -d -j .init test-gdb`.

### disas symbol

We can compile with option `-static` to create a static executable:

```bash
$ gcc -v 0701.c -static -o b.out
```

As per the `-static` link policy, it will assemble glibc(`libc.a`) into the final product `b.out`.

Check SYMBOL TABLE with `readelf -s` or `objdump -t`/`objdump -x` and we can see that `b.out` assembles/links a lot of CRT(C RunTime) and STD(C STanDard Library) implementation object files.

```bash
$ objdump -t b.out

b.out:     file format elf64-littleaarch64

SYMBOL TABLE:

[...snip...]

0000000000000000 l    df *ABS*	0000000000000000 crt1.o
0000000000000000 l    df *ABS*	0000000000000000 crti.o
0000000000000000 l    df *ABS*	0000000000000000 crtn.o
0000000000000000 l    df *ABS*	0000000000000000 exit.o
0000000000000000 l    df *ABS*	0000000000000000 cxa_atexit.o

[...snip...]

0000000000000000 l    df *ABS*	0000000000000000 stdio.o
0000000000000000 l    df *ABS*	0000000000000000 strcmp.o
0000000000000000 l    df *ABS*	0000000000000000 strcpy.o
0000000000000000 l    df *ABS*	0000000000000000 strlen.o
0000000000000000 l    df *ABS*	0000000000000000 strncmp.o
0000000000000000 l    df *ABS*	0000000000000000 strstr.o
0000000000000000 l    df *ABS*	0000000000000000 qsort.o

[...snip...]

```

Then type `nm -S` and grep function `strlen`, it lists five versions.

```bash
$ nm -S b.out | grep strlen
0000000000415650 0000000000000028 i __strlen
0000000000415650 0000000000000028 i strlen
0000000000418440 000000000000013c T __strlen_asimd
0000000000415650 0000000000000028 t __strlen_ifunc
00000000004183c0 0000000000000074 T __strlen_mte
```

If we type `objdump --disassemble=strlen b.out`, it fails to disassemble because the symbol type `i` indicates it's for the PE format.

Look at the other three symbols, they are local/global symbols in the text (code) section as the symbol type `t/T` indicates.

Try `objdump --disassemble=__strlen_ifunc b.out`, it disassembles successfully.

```bash
$ objdump --disassemble=__strlen_ifunc b.out

b.out:     file format elf64-littleaarch64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000415650 <__strlen_ifunc>:
  415650:	900003e2 	adrp	x2, 491000 <tunable_list+0x528>
  415654:	f0000001 	adrp	x1, 418000 <__memset_emag>
  415658:	f0000000 	adrp	x0, 418000 <__memset_emag>
  41565c:	91110021 	add	x1, x1, #0x440
  415660:	f9470c42 	ldr	x2, [x2, #3608]
  415664:	910f0000 	add	x0, x0, #0x3c0
  415668:	f9400042 	ldr	x2, [x2]
  41566c:	f26e005f 	tst	x2, #0x40000
  415670:	9a811000 	csel	x0, x0, x1, ne  // ne = any
  415674:	d65f03c0 	ret

Disassembly of section __libc_freeres_fn:

Disassembly of section .fini:
```

Another way is to calculate the start/stop address of the symbol `__strlen_ifunc` and invoke `objdump -d` with the options `--start-address` and `--stop-address`.

> objdump -d --start-address=0x415650 --stop-address=0x415678 b.out

The last way is to use [GDB disassemble](../toolchain/gdb/6-gdb-debug-assembly.md), according to [Ciro Santilli](https://stackoverflow.com/a/51971434/3721132).

```bash
$ man gdb
--batch
           Run in batch mode.
-e file
           Use file as the executable file to execute when appropriate
-x file
           Execute GDB commands from file.
```

Invoke GDB to load `file b.out` and execute `disassemble/rs 0x415650` to disassemble the symbol at the address in place.

```bash
$ gdb -batch -ex 'file b.out' -ex 'disassemble/rs 0x415650'
Dump of assembler code for function strlen:
   0x0000000000415650 <+0>:	e2 03 00 90	adrp	x2, 0x491000 <tunable_list+1320>
   0x0000000000415654 <+4>:	01 00 00 f0	adrp	x1, 0x418000 <__memset_emag>
   0x0000000000415658 <+8>:	00 00 00 f0	adrp	x0, 0x418000 <__memset_emag>
   0x000000000041565c <+12>:	21 00 11 91	add	x1, x1, #0x440
   0x0000000000415660 <+16>:	42 0c 47 f9	ldr	x2, [x2, #3608]
   0x0000000000415664 <+20>:	00 00 0f 91	add	x0, x0, #0x3c0
   0x0000000000415668 <+24>:	42 00 40 f9	ldr	x2, [x2]
   0x000000000041566c <+28>:	5f 00 6e f2	tst	x2, #0x40000
   0x0000000000415670 <+32>:	00 10 81 9a	csel	x0, x0, x1, ne  // ne = any
   0x0000000000415674 <+36>:	c0 03 5f d6	ret
End of assembler dump.
```

## intermix source+assembly

This final comprehensive example demonstrates disassembling the specified symbol/function with a mix of source code comment markers and line numbers.

- `[-S|--source]`: Display source code intermixed with disassembly, if possible. Implies `-d`.
- `[--source-comment[=text]]`: Like the `-S` option, but all source code lines are displayed with a prefix of txt(defaults to `#`).

From the output, we can see that the one-line simple C code `sum+=i;` is translated into four machine instructions. That's exactly what the compiler did behind the scenes. It sheds light on the working mechanism at a low level.

Read the source code and assembly against each other is the best way to get to grips with the essential of program and compilation.

```bash
# objdump -d --source-comment -l test-gdb
$ objdump --disassemble=func --source-comment -l test-gdb

test-gdb:     file format elf64-littleaarch64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000000754 <func>:
func():
/home/pifan/Projects/cpp/test-gdb.c:4
# #include <stdio.h>
#
# int func(int n)
# {
 754:	d10083ff 	sub	sp, sp, #0x20
 758:	b9000fe0 	str	w0, [sp, #12]
/home/pifan/Projects/cpp/test-gdb.c:5
#     int sum=0,i;
 75c:	b9001bff 	str	wzr, [sp, #24]
/home/pifan/Projects/cpp/test-gdb.c:6
#     for(i=0; i<n; i++)
 760:	b9001fff 	str	wzr, [sp, #28]
 764:	14000008 	b	784 <func+0x30>
/home/pifan/Projects/cpp/test-gdb.c:8 (discriminator 3)
#     {
#         sum+=i;
 768:	b9401be1 	ldr	w1, [sp, #24]
 76c:	b9401fe0 	ldr	w0, [sp, #28]
 770:	0b000020 	add	w0, w1, w0
 774:	b9001be0 	str	w0, [sp, #24]
/home/pifan/Projects/cpp/test-gdb.c:6 (discriminator 3)
#     for(i=0; i<n; i++)
 778:	b9401fe0 	ldr	w0, [sp, #28]
 77c:	11000400 	add	w0, w0, #0x1
 780:	b9001fe0 	str	w0, [sp, #28]
/home/pifan/Projects/cpp/test-gdb.c:6 (discriminator 1)
 784:	b9401fe1 	ldr	w1, [sp, #28]
 788:	b9400fe0 	ldr	w0, [sp, #12]
 78c:	6b00003f 	cmp	w1, w0
 790:	54fffecb 	b.lt	768 <func+0x14>  // b.tstop
/home/pifan/Projects/cpp/test-gdb.c:10
#     }
#     return sum;
 794:	b9401be0 	ldr	w0, [sp, #24]
/home/pifan/Projects/cpp/test-gdb.c:11
# }
 798:	910083ff 	add	sp, sp, #0x20
 79c:	d65f03c0 	ret

Disassembly of section .fini:
```
