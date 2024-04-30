---
title: GDB debug assembly
authors:
  - xman
date:
    created: 2022-04-26T10:00:00
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

[linux - How to debug assembly? - Stack Overflow](https://stackoverflow.com/questions/67669438/how-to-debug-assembly)

## Machine Code

[9.6 Source and Machine Code](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Machine-Code.html#Machine-Code)

help disassemble:

```Shell
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

showing mixed source+assembly with `/m` or `/s`.

!!! note "prefer /s to /m"

    The `/m` option is **deprecated** as its output is not useful when there is either inlined code or re-ordered code. The `/s` option is the **preferred** choice. Here is an example for AMD x86-64 showing the difference between `/m` output and `/s` output. This example has one *inline* function defined in a header file, and the code is compiled with ‘-O2’ optimization. Note how the `/m` output is missing the disassembly of several instructions that are present in the `/s` output.

参考示例 disas /m main 和 disas /s main 的区别。

### disas \_start

```Shell
(gdb) b _start
Breakpoint 1 at 0x640
(gdb) start
Temporary breakpoint 2 at 0x7b0: file test-gdb.c, line 16.
Starting program: /home/pifan/Projects/cpp/test-gdb

Breakpoint 1, 0x0000fffff7fd9c48 in _start () from /lib/ld-linux-aarch64.so.1
(gdb) disas /m _start
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

### disas func

```Shell
(gdb) disas /m func
Dump of assembler code for function func:
5	{
   0x0000aaaaaaaa0754 <+0>:	sub	sp, sp, #0x20
   0x0000aaaaaaaa0758 <+4>:	str	w0, [sp, #12]

6	    int sum=0,i;
=> 0x0000aaaaaaaa075c <+8>:	str	wzr, [sp, #24]

7	    for(i=0; i<n; i++)
   0x0000aaaaaaaa0760 <+12>:	str	wzr, [sp, #28]
   0x0000aaaaaaaa0764 <+16>:	b	0xaaaaaaaa0784 <func+48>
   0x0000aaaaaaaa0778 <+36>:	ldr	w0, [sp, #28]
   0x0000aaaaaaaa077c <+40>:	add	w0, w0, #0x1
   0x0000aaaaaaaa0780 <+44>:	str	w0, [sp, #28]
   0x0000aaaaaaaa0784 <+48>:	ldr	w1, [sp, #28]
   0x0000aaaaaaaa0788 <+52>:	ldr	w0, [sp, #12]
   0x0000aaaaaaaa078c <+56>:	cmp	w1, w0
   0x0000aaaaaaaa0790 <+60>:	b.lt	0xaaaaaaaa0768 <func+20>  // b.tstop

8	    {
9	        sum+=i;
   0x0000aaaaaaaa0768 <+20>:	ldr	w1, [sp, #24]
   0x0000aaaaaaaa076c <+24>:	ldr	w0, [sp, #28]
   0x0000aaaaaaaa0770 <+28>:	add	w0, w1, w0
   0x0000aaaaaaaa0774 <+32>:	str	w0, [sp, #24]

10	    }
11	    return sum;
   0x0000aaaaaaaa0794 <+64>:	ldr	w0, [sp, #24]

12	}
   0x0000aaaaaaaa0798 <+68>:	add	sp, sp, #0x20
   0x0000aaaaaaaa079c <+72>:	ret

End of assembler dump.
```

`-r` 选项以十六进制显示原始机器指令（不显示源代码）：

    (gdb) disas /r func
    Dump of assembler code for function func:
       0x0000000000000754 <+0>:	ff 83 00 d1	sub	sp, sp, #0x20
       0x0000000000000758 <+4>:	e0 0f 00 b9	str	w0, [sp, #12]
       0x000000000000075c <+8>:	ff 1b 00 b9	str	wzr, [sp, #24]
       0x0000000000000760 <+12>:	ff 1f 00 b9	str	wzr, [sp, #28]
       0x0000000000000764 <+16>:	08 00 00 14	b	0x784 <func+48>
       0x0000000000000768 <+20>:	e1 1b 40 b9	ldr	w1, [sp, #24]
       0x000000000000076c <+24>:	e0 1f 40 b9	ldr	w0, [sp, #28]
       0x0000000000000770 <+28>:	20 00 00 0b	add	w0, w1, w0
       0x0000000000000774 <+32>:	e0 1b 00 b9	str	w0, [sp, #24]
       0x0000000000000778 <+36>:	e0 1f 40 b9	ldr	w0, [sp, #28]
       0x000000000000077c <+40>:	00 04 00 11	add	w0, w0, #0x1
       0x0000000000000780 <+44>:	e0 1f 00 b9	str	w0, [sp, #28]
       0x0000000000000784 <+48>:	e1 1f 40 b9	ldr	w1, [sp, #28]
       0x0000000000000788 <+52>:	e0 0f 40 b9	ldr	w0, [sp, #12]
       0x000000000000078c <+56>:	3f 00 00 6b	cmp	w1, w0
       0x0000000000000790 <+60>:	cb fe ff 54	b.lt	0x768 <func+20>  // b.tstop
       0x0000000000000794 <+64>:	e0 1b 40 b9	ldr	w0, [sp, #24]
       0x0000000000000798 <+68>:	ff 83 00 91	add	sp, sp, #0x20
       0x000000000000079c <+72>:	c0 03 5f d6	ret

## auto display pc

[10 Examining Data](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Data.html#Data) - [10.8 Automatic Display](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Auto-Display.html#Auto-Display)

[Using gdb for Assembly Language Debugging](https://redirect.cs.umbc.edu/~cpatel2/links/310/nasm/gdb_help.shtml)

在 [Stopping and Continuing](./3-gdb-stop-and-continue.md) 中，我们想单步跟踪调试第 19 行 for 循环体的机器指令，每次 si 后都要执行 `disas /m func` 查看 pc 箭头指向当前运行到了那一条机器指令。有没有办法在 GDB 控制台中同步显示当前源码及其对应的机器指令呢？

格式 i 和 s 同样被 display 支持，一个非常有用的命令是：

```Shell
display/i $pc
```

\$pc 是 GDB 的环境变量，表示着指令的地址，/i 则表示输出格式为机器指令码，也就是汇编。

于是，当程序停下后，就会出现源代码和机器指令码相对应的情形，这是一个很有意思的功能。

gdb test-gdb 后，设置自动打印 pc，设置函数断点（b func），然后执行 `start` 启动运行（停止在 main 函数）。

```Shell
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

```Shell
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

```Shell
# execute for-control instruction 1
(gdb) n
6	    for(i=0; i<n; i++)
1: x/i $pc
=> 0xaaaaaaaa0760 <func+12>:	str	wzr, [sp, #28]

# next to for-body, execute instruction 1
```

再执行 `next` 运行到 func 函数中的 for 循环体语句（暂停在第 1 条指令），然后 si 3 次执行完循环体剩下的指令。

```Shell
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

`tui enable` / `tui disable`: 开启（Enable）进入 / 禁用（Disable）退出 TUI 模式。

```Shell
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

执行 `tui enable` 进入 TUI 模式，该模式主要涉及到  src（源码）、asm（汇编）、status（状态条） 和 cmd（命令）四个窗口（win）。

执行 `info win` 可以列举当前显示的窗口（win），默认打开源码窗口，中间是 status 状态栏，底下是 cmd 窗口部分。

```Shell
(gdb) info win
Name   Lines Columns Focus
src    34    100     (has focus)
status 1     100
cmd    18    100
```

执行 `layout` 命令可以切换窗口布局：

```Shell
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

在 TUI 模式下，可以执行 `tui focus name` / `focus name` 切换窗口焦点。

> Changes which TUI window is currently active for scrolling.

执行 `tui disable` 退出 TUI 模式，返回 GDB 控制台（console interpreter）。

*   ctrl + l(ell)：刷新窗口
*   ctrl + x，再按1：单窗口模式
*   ctrl + x，再按2：双窗口模式
*   ctrl + x，再按a：退出 TUI 模式