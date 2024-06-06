---
title: GDB Stop & Continue
authors:
  - xman
date:
    created: 2020-02-06T10:00:00
categories:
    - toolchain
tags:
    - gdb
    - breakpoint
comments: true
---

[5 Stopping and Continuing](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Stopping.html#Stopping)

在调试程序时，中断程序的运行是必须的。GDB 可以方便地暂停/继续程序的运行。

通过设置断点，可以决定程序在哪行，在什么条件下，或者在收到什么信号时暂停，以便查验程序运行的流程和状态。

程序暂停后，我们可以通过相关命令控制程序继续运行到下一个预设的中断点，在这种“暂停-继续”往复中调试验证程序设计的正确性。

<!-- more -->

## compile test program for debugging

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

gcc 编译命令：`cc test-gdb.c -o test-gdb -g`

```Shell title="test-gdb file format"
$ objdump -f test-gdb

test-gdb:     file format elf64-littleaarch64
architecture: aarch64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x0000000000000640

$ file test-gdb
test-gdb: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=65f667a433bbb8c27eeb9bab8db76816d07292dd, for GNU/Linux 3.7.0, with debug_info, not stripped
```

启动 gdb 调试：`gdb test-gdb`

在 gdb 中输入 `list` 查看源代码，确认行号以便下断点。

```Shell
(gdb) l 0
1	#include <stdio.h>
2	
3	int func(int n)
4	{
5	    int sum=0,i;
6	    for(i=0; i<n; i++)
7	    {
8	        sum+=i;
9	    }
10	    return sum;
(gdb)
11	}
12	
13	int main(int argc, char* argv[])
14	{
15	    int i;
16	    long result = 0;
17	    for(i=1; i<=100; i++)
18	    {
19	        result += i;
20	    }
(gdb)
21	
22	    printf("result[1-100] = %ld\n", result );
23	    printf("result[1-250] = %d\n", func(250) );
24	
25	    return 0;
26	}
(gdb)
Line number 27 out of range; test-gdb.c has 26 lines.
```

## Breakpoints, Watchpoints, and Catchpoints

[5.1 Breakpoints, Watchpoints, and Catchpoints](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Breakpoints.html#Breakpoints)

### breakpoints

[5.1.1 Setting Breakpoints](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Set-Breaks.html#Set-Breaks)
[5.1.6 Break Conditions](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Conditions.html#Conditions)

输入 `help breakpoints` 查看设置断点相关命令。以下摘录断点相关常用命令。

输入 `help break`，查看如何在特定位置设置断点（Set breakpoint at specified location.）。

`break` : b 不带任何参数，表示在下一条指令处停住。

> When called without any arguments, `break` sets a breakpoint at the next instruction to be executed in the selected stack frame (see [Examining the Stack](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Stack.html#Stack)).

`break locspec` : 在指定位置设置断点。

> Set a breakpoint at all the code locations in your program that result from resolving the given *locspec*. locspec can specify a function name, a line number, an address of an instruction, and more. See [Location Specifications](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Location-Specifications.html#Location-Specifications), for the various forms of locspec. 

| command                            | description                         | comment                                                  |
| ---------------------------------- | ----------------------------------- | -------------------------------------------------------- |
| break <function\>                  | 在进入指定函数后停住                          | C++中可以使用 class::function 或 function(type,type) 格式来指定函数名。 |
| break <linenum\>                   | 在指定行号停住。                            |                                                          |
| break +offset <br /> break -offset | 在当前行号的前/后偏移offset行处停住               | offiset为自然数                                              |
| break filename\:linenum            | 在源文件filename的linenum行处停住。           |                                                          |
| break filename\:function           | 在源文件filename的function函数的入口处停住。      |                                                          |
| break \*address                    | 在程序运行的内存地址处停住。                      | \*main + 4: fourth byte past main()                      |
| break … if cond                    | ...可以是上述的参数。condition表示条件，在条件成立时停住。 | 比如在循环境体中，可以设置 break if i==100，表示当i为100时停住程序。             |

临时断点（temp break）：只命中一次。

- `tbreak args`: Set a breakpoint enabled only for one stop. The args are the same as for the break command.

正则断点（regex break）：正则匹配断点。

*   `rbreak regex`: Set breakpoints on all functions matching the regular expression regex.
*   `rbreak file:regex`: If rbreak is called with a filename qualification, it limits the search for functions matching the given regular expression to the specified file.

使用 `rbreak .` 通配所有函数，即在所有函数处设置断点，方便 [逐函数调试](https://stackoverflow.com/questions/14694520/how-to-let-gdb-continue-until-the-program-enters-another-function/31249717#31249717)。为了防止频繁的匹配确认，可以提前执行 `set confirm off` 关闭确认。

以下执行 GDB `starti` 启动运行后，通过 `b _start` 设置断点，命中当前 interpreter `ld-linux-aarch64.so` 和 `libc.so` entry point 两个位置：

```bash
(gdb) starti
Starting program: /home/pifan/Projects/cpp/test-gdb

Program stopped.
0x0000fffff7fd9c40 in _start () from /lib/ld-linux-aarch64.so.1
(gdb) b _start
Breakpoint 1 at 0xaaaaaaaa0640 (2 locations)
(gdb) i b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   <MULTIPLE>
1.1                         y   0x0000aaaaaaaa0640 <_start>
1.2                         y   0x0000fffff7fd9c48 <_start+8>
```

在 main 函数、第 22 行、func 函数以及第 8 行下断点，其中第 8 行为条件断点。

> 注意 `b *main` 和 `b main` 断点位置的区别。*help break*: Address locations begin with "`*`" and specify an exact address in the program. Example: To specify the fourth byte past the start function "main", use "`*main + 4`".

```Shell
(gdb) b *main
Breakpoint 2 at 0x7a0: file test-gdb.c, line 14.
(gdb) b main
Breakpoint 1 at 0x7b0: file test-gdb.c, line 16.
(gdb) b 22
Breakpoint 2 at 0x7e8: file test-gdb.c, line 22.
(gdb) b func
Breakpoint 3 at 0x75c: file test-gdb.c, line 5.
(gdb) b 8 if i==50
Breakpoint 4 at 0x768: file test-gdb.c, line 8.
```

还可以通过指定地址 [break *addr](https://stackoverflow.com/questions/5459581/how-to-break-on-assembly-instruction-at-a-given-address-in-gdb) 的方式下断点：

```Shell
(gdb) starti
Starting program: /home/pifan/Projects/cpp/test-gdb

Program stopped.
0x0000fffff7fd9c40 in _start () from /lib/ld-linux-aarch64.so.1

# obtain symbol _start's stored address.
(gdb) i addr _start
Symbol "_start" is at 0xaaaaaaaa0640 in a file compiled without debugging.

# set breakpoint at specified address.
(gdb) b *0xaaaaaaaa0640
Breakpoint 1 at 0xaaaaaaaa0640

# obtain symbol main's stored address.
(gdb) i addr main
Symbol "main" is a function at address 0xaaaaaaaa07a0.

# set breakpoint at specified address, equivalent to b *main.
(gdb) b *0xaaaaaaaa07a0
Breakpoint 2 at 0xaaaaaaaa07a0: file test-gdb.c, line 14.

(gdb) i b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000aaaaaaaa0640 <_start>
2       breakpoint     keep y   0x0000aaaaaaaa07a0 in main at test-gdb.c:14
```

可使用 info 命令，查看已经配置的断点信息：

*   info breakpoints \[list…]
*   info break \[list…]

> Print a table of all breakpoints, watchpoints, tracepoints, and catchpoints set and not deleted. Optional argument `n` means print information only about the specified breakpoint(s) (or watchpoint(s) or tracepoint(s) or catchpoint(s)).

不指定断点号时，列出所有断点；否则只显示指定序号的断点信息，多个断点号之间以空格分开。

执行 `i b` 查看所有断点：

```Shell
(gdb) i b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x00000000000007b0 in main at test-gdb.c:16
2       breakpoint     keep y   0x00000000000007e8 in main at test-gdb.c:22
3       breakpoint     keep y   0x000000000000075c in func at test-gdb.c:5
4       breakpoint     keep y   0x0000000000000768 in func at test-gdb.c:8
	stop only if i==50
```

执行 `i b 1 3` 查看 1 号和 3 号断点：

```Shell
(gdb) i b 1 3
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x00000000000007b0 in main at test-gdb.c:16
3       breakpoint     keep y   0x000000000000075c in func at test-gdb.c:5
```

设置好断点后，执行 `run` 启动运行调试，测试断点的命中情况。

首先命中 1 号断点，在 main 函数的第一条语句/指令停下。

> 注意：int i 为暂时定义（tentative definition），实为声明，无指令。

```Shell
(gdb) r
Starting program: /home/pifan/Projects/cpp/test-gdb
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".

Breakpoint 1, main (argc=1, argv=0xfffffffff248) at test-gdb.c:16
16	    long result = 0;
```

### watchpoints

[5.1.2 Setting Watchpoints](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Set-Watchpoints.html#Set-Watchpoints)

观察点一般来观察某个表达式（变量也是一种表达式）的值是否有变化了，如果有变 化，马上停住程序。我们有下面的几种方法来设置观察点：

`watch <expr>` 为表达式（变量）expr设置一个观察点。一旦表达式值有变化，马上停住程序。

> watch \[-l|-location] expr \[thread thread-id] \[mask maskvalue] \[task task-id] : Set a watchpoint for an expression. GDB will break when the expression expr is written into by the program and its value changes.

`rwatch <expr>` 当表达式（变量）expr被读时，停住程序。

> rwatch \[-l|-location] expr \[thread thread-id] \[mask maskvalue] : Set a watchpoint that will break when the value of expr is read by the program.

`awatch <expr>` 当表达式（变量）的值被读或被写时，停住程序。

> awatch \[-l|-location] expr \[thread thread-id] \[mask maskvalue] : Set a watchpoint that will break when expr is either read from or written into by the program.

`info watchpoints` 列出当前所设置了的所有观察点。

> info watchpoints \[list…] : This command prints a list of watchpoints, using the same format as info break (see Set Breaks).

### commands

[5.1.7 Breakpoint Command Lists](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Break-Commands.html)

您可以为任何断点（或观察点或捕获点）提供一系列命令，以便在程序因该断点而停止时执行。例如，您可能想要打印某些表达式的值，或启用其他断点。

参考 [reloc puts@plt via GOT - pwndbg](../../elf/plt-puts-pwndbg.md) 中的使用案例：

在 C 程序进入 CRT entry point 之前，在 GOT entry `reloc.puts` 处设置观察点。进入 entry 之前，ld 会动态加载 libc.so，解析动态符号并修正 `reloc.puts` 指向的函数指针。这个 resovle/fix dynamic symbol 过程会更新 `reloc.puts` 内容，故会触发观察点（hardware watchpoint）。同时，触发观察点时，希望打印出真实符号地址的十六进制格式，故为观察点添加 commands。

You can use a watchpoint to add a sentry and stop execution whenever the value at 0xaaaaaaab0fc8 changes.

```bash
pwndbg> watch *(uintptr_t*)0xaaaaaaab0fc8
Hardware watchpoint 1: *(uintptr_t*)0xaaaaaaab0fc8
```

Then specify a command for the given watchpoint. Here we just hexdump the giant word stored in the memory.

```bash
pwndbg> commands 1
Type commands for breakpoint(s) 1, one per line.
End with a line saying just "end".
>x/xg 0xaaaaaaab0fc8
>end
```

Exec `info breakpoints|watchpoints` to check the status of breakpoints/watchpoints.

```bash
pwndbg> i b
Num     Type           Disp Enb Address            What
1       hw watchpoint  keep y                      *(uintptr_t*)0xaaaaaaab0fc8
        x/xg 0xaaaaaaab0fc8
```

## Continuing and Stepping

[5.2 Continuing and Stepping](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Continuing-and-Stepping.html#Continuing-and-Stepping)

### next

`next [count]`: Continue to the next source line in the current (innermost) stack frame. This is similar to step, but function calls that appear within the line of code are executed without stopping.

在 1 号断点 main 函数处停下后，输入 `n`（next）执行下一条语句：

```Shell
(gdb) n
17	    for(i=1; i<=100; i++)
```

不断输入 `n`，在 for 控制语句和循环体语句之间循环，直到循环结束（i=101）。

```Shell
(gdb) n
19	        result += i;
(gdb) n
17	    for(i=1; i<=100; i++)
```

执行完一次循环（i=1），即将进行第二次循环。此时，可以使用 `print` 命令查看循环变量 i 的值。

> [10 Examining Data](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Data.html#Data): The usual way to examine data in your program is with the `print` command (abbreviated `p`), or its synonym `inspect`. It evaluates and prints the value of an expression of the language your program is written.

```Shell
(gdb) p i
$6 = 1
```

执行 `n 6`，进行三轮循环后，i=4。

```Shell
(gdb) n 6
17	    for(i=1; i<=100; i++)
(gdb) p i
$7 = 4
```

`next` 命令是逐行源码（source line）执行，具体来说每次都停留在 C 语句对应的第一条机器指令处。

> The next command only stops at the *first* instruction of a source line.

如果想逐条调试每句 C 代码背后的机器指令序列，则需要使用 `nexti` 指令。

> `nexti` / `nexti arg`: Execute one machine instruction, but if it is a function call, proceed until the function returns.

在执行 nexti 之前，先执行 `disassemble` 命令反汇编 C 代码（函数），看看一行 C [源码背后对应的机器指令](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Machine-Code.html#Machine-Code)。

```Shell
(gdb) help disassemble
Disassemble a specified section of memory.
Usage: disassemble[/m|/r|/s] START [, END]
```

执行 `disas /m main` 反汇编 main 函数，可以看到循环控制条件语句在 AARCH64 上对应 9 条机器指令，循环体语句 `result += i` 则对应 4 条机器指令。箭头指向当前 pc：

```Shell
(gdb) disas /m main
Dump of assembler code for function main:

17	    for(i=1; i<=100; i++)
   0x0000aaaaaaaa07b4 <+20>:	mov	w0, #0x1                   	// #1
   0x0000aaaaaaaa07b8 <+24>:	str	w0, [sp, #36]
   0x0000aaaaaaaa07bc <+28>:	b	0xaaaaaaaa07dc <main+60>
   0x0000aaaaaaaa07d0 <+48>:	ldr	w0, [sp, #36]
   0x0000aaaaaaaa07d4 <+52>:	add	w0, w0, #0x1
   0x0000aaaaaaaa07d8 <+56>:	str	w0, [sp, #36]
   0x0000aaaaaaaa07dc <+60>:	ldr	w0, [sp, #36]
   0x0000aaaaaaaa07e0 <+64>:	cmp	w0, #0x64
   0x0000aaaaaaaa07e4 <+68>:	b.le	0xaaaaaaaa07c0 <main+32>

18	    {
19	        result += i;
=> 0x0000aaaaaaaa07c0 <+32>:	ldrsw	x0, [sp, #36]
   0x0000aaaaaaaa07c4 <+36>:	ldr	x1, [sp, #40]
   0x0000aaaaaaaa07c8 <+40>:	add	x0, x1, x0
   0x0000aaaaaaaa07cc <+44>:	str	x0, [sp, #40]

20	    }
```

执行 `nexti` 执行下一条指令，pc 箭头下移动：

```Shell
(gdb) ni
0x0000aaaaaaaa07c4	19	        result += i;

(gdb) disas /m main
Dump of assembler code for function main:

18	    {
19	        result += i;
   0x0000aaaaaaaa07c0 <+32>:	ldrsw	x0, [sp, #36]
=> 0x0000aaaaaaaa07c4 <+36>:	ldr	x1, [sp, #40]
   0x0000aaaaaaaa07c8 <+40>:	add	x0, x1, x0
   0x0000aaaaaaaa07cc <+44>:	str	x0, [sp, #40]

20	    }
```

执行 `info frame` 可查看当前栈帧信息（[Frame Info](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Frame-Info.html#Frame-Info)）: prints a verbose description of the selected stack frame.

```Shell
(gdb) i f
Stack level 0, frame at 0xfffffffff0d0:
 pc = 0xaaaaaaaa07c4 in main (test-gdb.c:19); saved pc = 0xfffff7e373fc
 source language c.
 Arglist at 0xfffffffff0a0, args: argc=1, argv=0xfffffffff248
 Locals at 0xfffffffff0a0, Previous frame's sp is 0xfffffffff0d0
 Saved registers:
  x29 at 0xfffffffff0a0, x30 at 0xfffffffff0a8
```

### continue

*   continue \[ignore-count]
*   fg \[ignore-count]

Resume program execution, at the address where your program last stopped; any breakpoints set at that address are bypassed.

The optional argument `ignore-count` allows you to specify a further number of times to ignore a breakpoint at this location; its effect is like that of ignore.

输入 `c`（continue），继续执行到下一个断点或结尾。这里命中第 22 行的 2 号断点。

```Shell
(gdb) c
Continuing.

Breakpoint 2, main (argc=1, argv=0xfffffffff248) at test-gdb.c:22
22	    printf("result[1-100] = %ld\n", result );
```

继续执行到 3 号断点，命中 func 函数的第一条指令。

```Shell
(gdb) c
Continuing.
result[1-100] = 5050

Breakpoint 3, func (n=250) at test-gdb.c:5
5	    int sum=0,i;
```

继续执行第 8 行的 4 号条件断点：

```Shell
(gdb) c
Continuing.

Breakpoint 4, func (n=250) at test-gdb.c:8
8	        sum+=i;
(gdb) p i
$1 = 50
```

### until

当你厌倦了在一个循环体内单步跟踪时，`until` 命令可以运行程序直到退出循环体。

> `until` / u: Continue running until a source line past the current line, in the current stack frame, is reached.

执行 [frame](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Frame-Info.html#Frame-Info) 命令 prints a brief description of the currently selected stack frame，确认当前运行到了哪里（暂停的位置）。

```Shell
(gdb) f
#0  main (argc=1, argv=0xfffffffff248) at test-gdb.c:17
17	    for(i=1; i<=100; i++)
(gdb) l
12	
13	int main(int argc, char* argv[])
14	{
15	    int i;
16	    long result = 0;
17	    for(i=1; i<=100; i++)
18	    {
19	        result += i;
20	    }
21	
(gdb)
22	    printf("result[1-100] = %ld\n", result );
23	    printf("result[1-250] = %d\n", func(250) );
24	
25	    return 0;
26	}
```

输入 `u`（或 `u 22`），跳出第 17-20 行的 for 循环，运行到第 22 行暂停。

```Shell
(gdb) u
main (argc=1, argv=0xfffffffff248) at test-gdb.c:22
22	    printf("result[1-100] = %ld\n", result );
```

此时，断在第 22 行的 printf 调用，执行 `next` 运行至第 23 行。

如果继续执行 `next` 不会进入 func 和 printf 函数内部，直接运行至 return 语句。

要想进入 func 函数体内部进行调试，则需要改用 `step` 单步跟踪命令。

### next vs. step

COMMAND | SHORTCUT | DESCRIPTION
--------|:--------:|------------
next n  | n        | Next [n] line[s] (stepping over function calls)
step n  | s        | Next [n] line[s] (stepping into function calls)
nexti n | ni       | Next [n] instruction[s] (stepping over function calls)
stepi n | si       | Next [n] instruction[s] (stepping into function calls)

### step/finish

`step`：单步跟踪，如果有函数调用，会进入该函数，类似VC等工具中的 step in。而 `next` 遇到函数调用，不会进入该函数。类似VC等工具中的 step over。

> `step`: Continue running your program until control reaches a different source line, then stop it and return control to GDB. This command is abbreviated `s`.

> `step count`: Continue running as in step, but do so count times. If a breakpoint is reached, or a signal not related to stepping occurs before count steps, stepping stops right away.

> 与 nexti（ni）对应有 stepi（si）命令，支持机器指令级别的单步调试。

执行 `step` 跟踪进入 func 函数体第 5 行代码。

```Shell
(gdb) s
func (n=250) at test-gdb.c:5
5	    int sum=0,i;
```

如果不想在 func 中逗留，可以执行 `finish` 命令运行至当前函数返回，并打印函数返回时的堆栈地址和返回值及参数值等信息。类似 VC 等工具中的 step out。

> `finish`: Continue running until just after function in the selected stack frame returns. Print the returned value (if any). This command can be abbreviated as `fin`.

```Shell
(gdb) fin
Run till exit from #0  func (n=250) at test-gdb.c:5
0x0000aaaaaaaa0800 in main (argc=1, argv=0xfffffffff248) at test-gdb.c:23
23	    printf("result[1-250] = %d\n", func(250) );
Value returned is $10 = 31125
```

从 func 返回到第 23 行的 printf 语句，如果继续 `step` 将深入 printf 函数内部，提示找不到源代码。
执行 finish 退出 printf 函数体，返回到第 25 行的 return 语句。

```Shell
(gdb) s
__printf (format=0xaaaaaaaa0850 "result[1-250] = %d\n") at ./stdio-common/printf.c:28
28	./stdio-common/printf.c: No such file or directory.

(gdb) fin
Run till exit from #0  __printf (format=0xaaaaaaaa0850 "result[1-250] = %d\n") at ./stdio-common/printf.c:28
result[1-250] = 31125
main (argc=1, argv=0xfffffffff248) at test-gdb.c:25
25	    return 0;
Value returned is $11 = 22
```

### skip

[5.3 Skipping Over Functions and Files](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Skipping-Over-Functions-and-Files.html#Skipping-Over-Functions-and-Files)

The program you are debugging may contain some functions which are uninteresting to debug. The `skip` command lets you tell GDB to *skip* a function, all functions in a file or a particular function in a particular file when stepping.

For example, consider the following C function:

```c linenums="101"
int func()
{
    foo(boring());
    bar(boring());
}
```

Suppose you wish to step into the functions foo and bar, but you are not interested in stepping through boring. If you run step at line 103, you’ll enter boring(), but if you run next, you’ll step over both foo and boring!

One solution is to `step` into boring and use the `finish` command to immediately exit it. But this can become tedious if boring is called from many places.

A more flexible solution is to execute `skip boring`. This instructs GDB never to step into boring. Now when you execute step at line 103, you’ll step over boring and directly into foo.

在上面执行 step 单步跟踪的例子中，可以 `skip printf` 不跟踪进入 printf 函数体。

和 breakpoints/watchpoints 一样，skip points 也支持 info 查看和 enable/disable/delete 管理操作：

*   `info skip [range]`: Print details about the specified skip(s).
*   `skip delete [range]`:  Delete the specified skip(s). If range is not specified, delete all skips.
*   `skip enable [range]`: Enable the specified skip(s). If range is not specified, enable all skips.
*   `skip disable [range]`: Disable the specified skip(s). If range is not specified, disable all skips.

## Manage Breakpoints

对于设置的停止点，可以 disable 禁用，也可以 enable 重新启用，或者 delete 删除。

### enable/disable

[5.1.5 Disabling Breakpoints](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Disabling.html#Disabling)

You can use the following commands to enable or disable breakpoints, watchpoints, tracepoints, and catchpoints:

```Shell
disable [breakpoints] [list…]
Disable the specified breakpoints—or all breakpoints, if none are listed. A disabled breakpoint has no effect but is not forgotten. All options such as ignore-counts, conditions and commands are remembered in case the breakpoint is enabled again later. You may abbreviate disable as dis.

enable [breakpoints] [list…]
Enable the specified breakpoints (or all defined breakpoints). They become effective once again in stopping your program.

enable [breakpoints] once list…
Enable the specified breakpoints temporarily. GDB disables any of these breakpoints immediately after stopping your program.

enable [breakpoints] count count list…
Enable the specified breakpoints temporarily. GDB records count with each of the specified breakpoints, and decrements a breakpoint’s count when it is hit. When any count reaches 0, GDB disables that breakpoint. If a breakpoint has an ignore count (see Break Conditions), that will be decremented to 0 before count is affected.

enable [breakpoints] delete list…
Enable the specified breakpoints to work once, then die. GDB deletes any of these breakpoints as soon as your program stops there. Breakpoints set by the tbreak command start out in this state.
```

### delete

[5.1.4 Deleting Breakpoints](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Delete-Breaks.html#Delete-Breaks)

`clear`: 清除下一个停止点。

Delete any breakpoints at the next instruction to be executed in the selected stack frame (see [Selecting a Frame](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Selection.html#Selection)). When the innermost frame is selected, this is a good way to delete a breakpoint where your program just stopped.

`clear locspec`，与 `break locspec` 对应，支持清除指定行号、函数和地址处的停止点。

Delete any breakpoint with a code location that corresponds to locspec. See [Location Specifications](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Location-Specifications.html#Location-Specifications), for the various forms of locspec.

*   linenum
*   filename\:linenum
*   \-line linenum
*   \-source filename -line linenum
*   \*address
*   function / -function function

`delete [breakpoints] [list…]`

Delete the breakpoints, watchpoints, tracepoints, or catchpoints of the breakpoint list specified as argument. If no argument is specified, delete *all* breakpoints, watchpoints, tracepoints, and catchpoints (GDB asks confirmation, unless you have `set confirm off`). You can abbreviate this command as `d`.

删除指定的断点，breakpoints为断点号。如果不指定断点号，则表示删除所有的断点。

```Shell
(gdb) i b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000aaaaaaaa07b0 in main at test-gdb.c:16
	breakpoint already hit 1 time
2       breakpoint     keep y   0x0000aaaaaaaa07e8 in main at test-gdb.c:22
3       breakpoint     keep y   0x0000aaaaaaaa075c in func at test-gdb.c:5
4       breakpoint     keep y   0x0000aaaaaaaa0768 in func at test-gdb.c:8
	stop only if i==50
	
# 清除下一个断点（1 号断点）
(gdb) clear
Deleted breakpoint 1

# 删除 2 号断点
(gdb) d 2

# 删除第 8 行的停止点（4 号断点）
(gdb) clear 8
Deleted breakpoint 4

(gdb) i b
Num     Type           Disp Enb Address            What
3       breakpoint     keep y   0x0000aaaaaaaa075c in func at test-gdb.c:5

(gdb) d
Delete all breakpoints? (y or n) y
```
