---
title: GDB debug assembly
authors:
  - xman
date:
    created: 2020-02-09T10:00:00
categories:
    - toolchain
tags:
    - gdb
    - disassemble
comments: true
---

This article involves the following topics:

1. How to disassemble source code to machine code?
2. How to dump machine instruction along with source line?
3. How to layout src and asm side by side in a single gdb window?

<!-- more -->

## gcc -fverbose-asm

GCC [Code Gen Options](https://gcc.gnu.org/onlinedocs/gcc-13.2.0/gcc/Code-Gen-Options.html) 提供了 `-fverbose-asm` 选项，在生成的汇编代码中添加额外的注释信息和汇编指令对应的源代码信息，以使其更具可读性。

!!! note ""

    Put ***extra*** commentary information in the generated assembly code to make it more readable. This option is generally only of use to those who actually need to read the generated assembly code (perhaps while debugging the compiler itself).

    `-fno-verbose-asm`, the default, causes the extra information to be omitted and is useful when comparing two assembler files.

    The added comments include:

    - information on the compiler version and command-line options,
    - the *source code lines* associated with the assembly instructions, in the form FILENAME:LINENUMBER:CONTENT OF LINE,
    - hints on which high-level expressions correspond to the various assembly instruction operands.

其中给出了一个编译范例：`gcc -S test.c -fverbose-asm -Os -o -`，可以很方便的分析源代码对应的汇编代码。

在 GDB console 中，也可以使用 `disassemble` 命令，反汇编显示当前上下文的汇编代码，也可以反汇编指定函数。

使用 next/step 可以逐行、逐函数调试 C 源代码，使用 nexti/stepi 命令则可以切换调试源代码对应的汇编指令。

借助 `display` 命令可以显示当前 pc 中的指令，这样可以很方便地在源码和汇编级别切换调试。

## disassemble

[9.6 Source and Machine Code](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Machine-Code.html#Machine-Code)

help disassemble:

```bash
(gdb) help disas
Disassemble a specified section of memory.
Usage: disassemble[/m|/r|/s] START [, END]
Default is the function surrounding the pc of the selected frame.

With a /s modifier, source lines are included (if available).
In this mode, the output is displayed in PC address order, and
file names and contents for all relevant source files are displayed.

With a /m modifier, source lines are included (if available).
This view is "source centric": the output is in source line order,
regardless of any optimization that is present.  Only the main source file
is displayed, not those of, e.g., any inlined functions.
This modifier hasn't proved useful in practice and is deprecated
in favor of /s.

With a /r modifier, raw instructions in hex are included.

With a single argument, the function surrounding that address is dumped.
Two arguments (separated by a comma) are taken as a range of memory to dump,
  in the form of "start,end", or "start,+length".

Note that the address is interpreted as an expression, not as a location
like in the "break" command.
So, for example, if you want to disassemble function bar in file foo.c
you must type "disassemble 'foo.c'::bar" and not "disassemble foo.c:bar".
```

当不带参数执行 `disassemble` 命令时，默认反汇编当前 pc 周边的代码。

> The default memory range is the function surrounding the program counter of the selected frame.

Show mixed source+assembly with `/m`(mixed source) or `/s`(source).

`/m` 为 source line order，忽略了一些内联展开（inlined code）和指令重排（re-ordered）优化，`/s` 为实际运行的 PC address order。

参考官网在线文档给出的示例，对比 disas /m main 和 disas /s main 输出，分析优化前后指令序列的区别。

!!! note "prefer /s to /m"

    The `/m` option is **deprecated** as its output is not useful when there is either inlined code or re-ordered code. The `/s` option is the **preferred** choice. Here is an example for AMD x86-64 showing the difference between `/m` output and `/s` output. This example has one *inline* function defined in a header file, and the code is compiled with ‘-O2’ optimization. Note how the `/m` output is missing the disassembly of several instructions that are present in the `/s` output.

初步学习对比 src 到 asm 的直接翻译，可以使用 `/m` 选项；考虑 ni/si 单步跟踪指令序列的实际运行，则建议使用 `/s` 选项。

### disas \_start

在终端输入 `gdb test-gdb` 启动 GDB Console。

```bash
# tb _start + run
(gdb) disas _start
Dump of assembler code for function _start:
   0x0000000000000640 <+0>:	nop
   0x0000000000000644 <+4>:	mov	x29, #0x0                   	// #0
   0x0000000000000648 <+8>:	mov	x30, #0x0                   	// #0
   0x000000000000064c <+12>:	mov	x5, x0
   0x0000000000000650 <+16>:	ldr	x1, [sp]
   0x0000000000000654 <+20>:	add	x2, sp, #0x8
   0x0000000000000658 <+24>:	mov	x6, sp
   0x000000000000065c <+28>:	adrp	x0, 0x10000
   0x0000000000000660 <+32>:	ldr	x0, [x0, #4080]
   0x0000000000000664 <+36>:	mov	x3, #0x0                   	// #0
   0x0000000000000668 <+40>:	mov	x4, #0x0                   	// #0
   0x000000000000066c <+44>:	bl	0x5f0 <__libc_start_main@plt>
   0x0000000000000670 <+48>:	bl	0x620 <abort@plt>
End of assembler dump.
```

在 GDB 中输入 `starti` 将在 ld.so 的 `_start` 函数处停住，这是整个程序第一条指令的地址。

```bash hl_lines="16"
(gdb) starti
Starting program: /home/pifan/Projects/cpp/test-gdb

Program stopped.
0x0000fffff7fd9c40 in _start () from /lib/ld-linux-aarch64.so.1

(gdb) disas _start
Dump of assembler code for function _start:
   0x0000aaaaaaaa0640 <+0>:	nop
   0x0000aaaaaaaa0644 <+4>:	mov	x29, #0x0                   	// #0
   0x0000aaaaaaaa0648 <+8>:	mov	x30, #0x0                   	// #0
   0x0000aaaaaaaa064c <+12>:	mov	x5, x0
   0x0000aaaaaaaa0650 <+16>:	ldr	x1, [sp]
   0x0000aaaaaaaa0654 <+20>:	add	x2, sp, #0x8
   0x0000aaaaaaaa0658 <+24>:	mov	x6, sp
   0x0000aaaaaaaa065c <+28>:	adrp	x0, 0xaaaaaaab0000
   0x0000aaaaaaaa0660 <+32>:	ldr	x0, [x0, #4080]
   0x0000aaaaaaaa0664 <+36>:	mov	x3, #0x0                   	// #0
   0x0000aaaaaaaa0668 <+40>:	mov	x4, #0x0                   	// #0
   0x0000aaaaaaaa066c <+44>:	bl	0xaaaaaaaa05f0 <__libc_start_main@plt>
   0x0000aaaaaaaa0670 <+48>:	bl	0xaaaaaaaa0620 <abort@plt>
End of assembler dump.
```

接下来，可使用 nexti/stepi 进行汇编指令级调试。

### disas func

以下对比 GDB `disas` 和 GNU binutils 中的 `objdump` 反汇编 func 函数的输出：

=== "disas /s func"

    ```bash
    (gdb) disas /s func
    Dump of assembler code for function func:
    test-gdb.c:
    4	{
    0x0000aaaaaaaa0754 <+0>:	sub	sp, sp, #0x20
    0x0000aaaaaaaa0758 <+4>:	str	w0, [sp, #12]

    5	    int sum=0,i;
    0x0000aaaaaaaa075c <+8>:	str	wzr, [sp, #24]

    6	    for(i=0; i<n; i++)
    0x0000aaaaaaaa0760 <+12>:	str	wzr, [sp, #28]
    0x0000aaaaaaaa0764 <+16>:	b	0xaaaaaaaa0784 <func+48>

    7	    {
    8	        sum+=i;
    0x0000aaaaaaaa0768 <+20>:	ldr	w1, [sp, #24]
    0x0000aaaaaaaa076c <+24>:	ldr	w0, [sp, #28]
    0x0000aaaaaaaa0770 <+28>:	add	w0, w1, w0
    0x0000aaaaaaaa0774 <+32>:	str	w0, [sp, #24]

    6	    for(i=0; i<n; i++)
    0x0000aaaaaaaa0778 <+36>:	ldr	w0, [sp, #28]
    0x0000aaaaaaaa077c <+40>:	add	w0, w0, #0x1
    0x0000aaaaaaaa0780 <+44>:	str	w0, [sp, #28]
    0x0000aaaaaaaa0784 <+48>:	ldr	w1, [sp, #28]
    0x0000aaaaaaaa0788 <+52>:	ldr	w0, [sp, #12]
    0x0000aaaaaaaa078c <+56>:	cmp	w1, w0
    0x0000aaaaaaaa0790 <+60>:	b.lt	0xaaaaaaaa0768 <func+20>  // b.tstop

    9	    }
    10	    return sum;
    0x0000aaaaaaaa0794 <+64>:	ldr	w0, [sp, #24]

    11	}
    0x0000aaaaaaaa0798 <+68>:	add	sp, sp, #0x20
    0x0000aaaaaaaa079c <+72>:	ret
    End of assembler dump.
    ```

=== "objdump --disassemble=func -S"

    ```asm
    (gdb) !objdump --disassemble=func -S --source-comment test-gdb

    test-gdb:     file format elf64-littleaarch64


    Disassembly of section .init:

    Disassembly of section .plt:

    Disassembly of section .text:

    0000000000000754 <func>:
    # #include <stdio.h>
    #
    # int func(int n)
    # {
    754:	d10083ff 	sub	sp, sp, #0x20
    758:	b9000fe0 	str	w0, [sp, #12]
    #     int sum=0,i;
    75c:	b9001bff 	str	wzr, [sp, #24]
    #     for(i=0; i<n; i++)
    760:	b9001fff 	str	wzr, [sp, #28]
    764:	14000008 	b	784 <func+0x30>
    #     {
    #         sum+=i;
    768:	b9401be1 	ldr	w1, [sp, #24]
    76c:	b9401fe0 	ldr	w0, [sp, #28]
    770:	0b000020 	add	w0, w1, w0
    774:	b9001be0 	str	w0, [sp, #24]
    #     for(i=0; i<n; i++)
    778:	b9401fe0 	ldr	w0, [sp, #28]
    77c:	11000400 	add	w0, w0, #0x1
    780:	b9001fe0 	str	w0, [sp, #28]
    784:	b9401fe1 	ldr	w1, [sp, #28]
    788:	b9400fe0 	ldr	w0, [sp, #12]
    78c:	6b00003f 	cmp	w1, w0
    790:	54fffecb 	b.lt	768 <func+0x14>  // b.tstop
    #     }
    #     return sum;
    794:	b9401be0 	ldr	w0, [sp, #24]
    # }
    798:	910083ff 	add	sp, sp, #0x20
    79c:	d65f03c0 	ret

    Disassembly of section .fini:
    ```

`-r` 选项以十六进制显示原始机器指令（raw instructions），不显示源代码：

- 也可以 `disas /rs` 同时显示机器指令编码和源码。

```bash
(gdb) disas /r func
Dump of assembler code for function func:
   0x0000aaaaaaaa0754 <+0>:	ff 83 00 d1	sub	sp, sp, #0x20
   0x0000aaaaaaaa0758 <+4>:	e0 0f 00 b9	str	w0, [sp, #12]
   0x0000aaaaaaaa075c <+8>:	ff 1b 00 b9	str	wzr, [sp, #24]
   0x0000aaaaaaaa0760 <+12>:	ff 1f 00 b9	str	wzr, [sp, #28]
   0x0000aaaaaaaa0764 <+16>:	08 00 00 14	b	0xaaaaaaaa0784 <func+48>
   0x0000aaaaaaaa0768 <+20>:	e1 1b 40 b9	ldr	w1, [sp, #24]
   0x0000aaaaaaaa076c <+24>:	e0 1f 40 b9	ldr	w0, [sp, #28]
   0x0000aaaaaaaa0770 <+28>:	20 00 00 0b	add	w0, w1, w0
   0x0000aaaaaaaa0774 <+32>:	e0 1b 00 b9	str	w0, [sp, #24]
   0x0000aaaaaaaa0778 <+36>:	e0 1f 40 b9	ldr	w0, [sp, #28]
   0x0000aaaaaaaa077c <+40>:	00 04 00 11	add	w0, w0, #0x1
   0x0000aaaaaaaa0780 <+44>:	e0 1f 00 b9	str	w0, [sp, #28]
   0x0000aaaaaaaa0784 <+48>:	e1 1f 40 b9	ldr	w1, [sp, #28]
   0x0000aaaaaaaa0788 <+52>:	e0 0f 40 b9	ldr	w0, [sp, #12]
   0x0000aaaaaaaa078c <+56>:	3f 00 00 6b	cmp	w1, w0
   0x0000aaaaaaaa0790 <+60>:	cb fe ff 54	b.lt	0xaaaaaaaa0768 <func+20>  // b.tstop
   0x0000aaaaaaaa0794 <+64>:	e0 1b 40 b9	ldr	w0, [sp, #24]
   0x0000aaaaaaaa0798 <+68>:	ff 83 00 91	add	sp, sp, #0x20
   0x0000aaaaaaaa079c <+72>:	c0 03 5f d6	ret
End of assembler dump.
```

Instructions are still 4-byte(32 bits) long and mostly the same as A32.

## auto display

[10 Examining Data](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Data.html#Data) - [10.8 Automatic Display](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Auto-Display.html#Auto-Display)

[Using gdb for Assembly Language Debugging](https://redirect.cs.umbc.edu/~cpatel2/links/310/nasm/gdb_help.shtml)

在 [Stopping and Continuing](./3-gdb-stop-and-continue.md) 中，我们想单步跟踪调试第 19 行 for 循环体的机器指令，每次 si 后都要执行 `disas /m func` 查看 pc 箭头指向当前运行到了那一条机器指令。有没有办法在 GDB 控制台中同步显示当前源码及其对应的机器指令呢？

格式 i 和 s 同样被 display 支持，一个非常有用的命令是 `display/i $pc`。

> It is often useful to do `display/i $pc` when stepping by machine instructions.
> This makes GDB automatically display the *next* instruction to be executed, each time your program stops.

\$pc 是 GDB 的环境变量，表示着指令的地址，/i 则表示输出格式为机器指令码，也就是汇编。

于是，当程序停下后，就会出现源代码和机器指令码相对应的情形，这是一个很有意思的功能。

gdb test-gdb 后，设置自动打印 pc，设置函数断点（b func），然后执行 `start` 启动运行（停止在 main 函数）。

```bash
# 设置自动打印 pc
(gdb) display/i $pc
1: x/i $pc
<error: No registers.>

# 设置函数断点
(gdb) b func
Breakpoint 1 at 0x75c: file test-gdb.c, line 5.

# 启动运行（tbreak main）
(gdb) start
Temporary breakpoint 2 at 0x7b0: file test-gdb.c, line 16.
Starting program: /home/pifan/Projects/cpp/test-gdb
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".

Temporary breakpoint 2, main (argc=1, argv=0xfffffffff358) at test-gdb.c:16
16	    long result = 0;
1: x/i $pc
=> 0xaaaaaaaa07b0 <main+16>:	str	xzr, [sp, #40]
```

执行 `continue` 运行到下一个断点，即 func 函数断点，运行至函数体中的第一条语句。

```bash
# continue to next breakpoint
(gdb) c
Continuing.
result[1-100] = 5050

Breakpoint 1, func (n=250) at test-gdb.c:5
5	    int sum=0,i;
1: x/i $pc
=> 0xaaaaaaaa075c <func+8>:	str	wzr, [sp, #24]
```

执行 `next` 运行到 func 函数中的 for 循环条件语句。

```bash
# execute for-control instruction 1
(gdb) n
6	    for(i=0; i<n; i++)
1: x/i $pc
=> 0xaaaaaaaa0760 <func+12>:	str	wzr, [sp, #28]

# next to for-body, execute instruction 1
```

再执行 `next` 运行到 func 函数中的 for 循环体语句（暂停在第 1 条指令），然后 si 3 次执行完循环体剩下的指令。

```bash
# next stops at the first instruction of for-body source line
(gdb) n
8	        sum+=i;
1: x/i $pc
=> 0xaaaaaaaa0768 <func+20>:	ldr	w1, [sp, #24]

# si execute for-body instruction 2
(gdb) si
0x0000aaaaaaaa076c	8	        sum+=i;
1: x/i $pc
=> 0xaaaaaaaa076c <func+24>:	ldr	w0, [sp, #28]

# si execute for-body instruction 3
(gdb)
0x0000aaaaaaaa0770	8	        sum+=i;
1: x/i $pc
=> 0xaaaaaaaa0770 <func+28>:	add	w0, w1, w0

# si execute for-body instruction 4
(gdb)
0x0000aaaaaaaa0774	8	        sum+=i;
1: x/i $pc
=> 0xaaaaaaaa0774 <func+32>:	str	w0, [sp, #24]

# si execute for-control instruction 1
(gdb)
6	    for(i=0; i<n; i++)
1: x/i $pc
=> 0xaaaaaaaa0778 <func+36>:	ldr	w0, [sp, #28]
```

si 单步跟踪 C 语句 `sum += i`，每次自动打印该步运行的机器指令，这正是我们预期的调试效果。

## tui layout

[25.5 TUI-specific Commands](https://sourceware.org/gdb/current/onlinedocs/gdb.html/TUI-Commands.html)

[gdb调试的layout使用](https://blog.csdn.net/zhangjs0322/article/details/10152279)

`show tui` 可以查看 TUI 配置变量（configuration variables）。

`tui enable` / `tui disable`: 开启进入 / 禁用退出 TUI 模式。

```bash
(gdb) help tui
Text User Interface commands.

List of tui subcommands:

tui disable -- Disable TUI display mode.
tui enable -- Enable TUI display mode.
tui new-layout -- Create a new TUI layout.
tui reg -- TUI command to control the register window.

Type "help tui" followed by tui subcommand name for full documentation.
Type "apropos word" to search for commands related to "word".
Type "apropos -v word" for full documentation of commands related to "word".
Command name abbreviations are allowed if unambiguous.
```

执行 `tui enable` 进入 TUI 模式，该模式主要涉及到 src（源码）、asm（汇编）、status（状态条） 和 cmd（命令）四个窗口（win）。

执行 `info win` 可以列举当前显示的窗口（win），默认打开 src 源码窗口，中间是 status 状态栏，底下是 cmd 窗口部分。

```bash
(gdb) info win
Name   Lines Columns Focus
src    34    100     (has focus)
status 1     100
cmd    18    100
```

执行 `layout` 命令可以切换窗口布局：

```bash
(gdb) help layout
Change the layout of windows.
Usage: layout prev | next | LAYOUT-NAME

List of layout subcommands:

layout asm -- Apply the "asm" layout.
layout next -- Apply the next TUI layout.
layout prev -- Apply the previous TUI layout.
layout regs -- Apply the TUI register layout.
layout split -- Apply the "split" layout.
layout src -- Apply the "src" layout.

Type "help layout" followed by layout subcommand name for full documentation.
Type "apropos word" to search for commands related to "word".
Type "apropos -v word" for full documentation of commands related to "word".
Command name abbreviations are allowed if unambiguous.
```

`tui enable` 使能 TUI 模式后，相当于 `layout src`。我们可以改变窗口布局：

*   `layout asm` 打开汇编代码。
*   `layout split` 同时打开 src 和 asm（上下窗格布局）。

在 src 窗口，`layout next` 依次切换到 asm、src+asm（上下布局）、regs+src（上下布局）、regs+asm（上下布局）。

在 split 模式下，同步显示 src+asm，非常方便 ni/si 单步跟踪调试机器指令。

在 TUI 模式下，可以执行 `[tui] focus name` 切换窗口焦点。

> Changes which TUI window is currently active for scrolling.

此外，还可通过 `winheight` 命令调整窗口高度：

- `winheight name +count`: winheight src -5，将源码窗口降低 5 行。
- `winheight name -count`: winheight asm +10，将汇编窗口增高 10 行。

执行 `tui disable` 退出 TUI 模式，返回 GDB 控制台（console interpreter）。

*   ctrl + l(ell)：刷新窗口
*   ctrl + x，再按1：单窗口模式
*   ctrl + x，再按2：双窗口模式
*   ctrl + x，再按a：退出 TUI 模式

当然，我们也可以安装 GDB 增强扩展插件 `GEF` 或 `pwndbg`，参考下篇《[GDB Enhanced Extensions](./7-gdb-enhanced.md)》。
