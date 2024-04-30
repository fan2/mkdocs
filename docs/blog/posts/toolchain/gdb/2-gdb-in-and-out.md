---
title: GDB Invocation & Quitting
authors:
  - xman
date:
    created: 2022-04-22T10:00:00
categories:
    - toolchain
tags:
    - gdb
comments: true
---

[Invocation (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Invocation.html#Invocation)

This article discusses how to start GDB, and how to get out of it.

- type `gdb` to start GDB.
- type `quit`, `exit` or <kbd>ctrl</kbd>+<kbd>d</kbd> to exit.

And how to show source file info about the program being debugged.

<!-- more -->

## Invoking

[Invoking GDB (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Invoking-GDB.html#Invoking-GDB)

gcc 编译链接 C 代码，添加 `-g` 选项生成调试信息。

```Shell
cc helloc.c -o helloc -g
c++ hellocpp.cpp -o hellocpp -g
```

执行 `gdb helloc` 启动 gdb 调试 gcc 编译好的 helloc。

### file

[18 GDB Files | 18.1 Commands to Specify Files](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Files.html)

```Shell
(gdb) help file
Use FILE as program to be debugged.
```

如果不带参数执行 `gdb` 启动 REPL，未指定 executable file 和 symbol file。

```Shell
(gdb) r
Starting program:
No executable file specified.
Use the "file" or "exec-file" command.

(gdb) file
No executable file now.
No symbol file now.
```

可执行 `file` 指定要调试的文件：

```Shell
(gdb) file helloc
Reading symbols from helloc...
```

中途可以使用该命令加载切换新的调试目标文件（Load new symbol table）。

其他参考：[17.7 Compiling and injecting code in GDB](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Compiling-and-Injecting-Code.html#Compiling-and-Injecting-Code)

### attach process

You can, instead, specify a process ID as a second argument or use option `-p`, if you want to debug a running process:

```Shell
gdb program 1234
```

`gdb -p 1234` would attach GDB to process 1234. With option `-p` you can omit the program filename.

[Attach (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Attach.html#Attach)

## info && list

### info

```Shell
(gdb) help info
info, inf, i
Generic command for showing things about the program being debugged.

List of info subcommands:

info files -- Names of targets and files being debugged.

info source -- Information about the current source file.
info sources -- All source files in the program or those matching REGEXP.
```

执行 `info file` 列举当前已加载符号的调试文件：

```Shell
(gdb) info file
Symbols from "/home/pifan/Projects/cpp/helloc".
Local exec file:
	`/home/pifan/Projects/cpp/helloc', file type elf64-littleaarch64.
	Entry point: 0x640

...
```

> run/start 运行起来后，Entry point 会变成虚拟地址（VMA）。

执行 `info source` 查看正在调试的源代码文件信息：

```Shell
(gdb) info source
Current source file is helloc.c
Compilation directory is /home/pifan/Projects/cpp
Located in /home/pifan/Projects/cpp/helloc.c
Contains 7 lines.
Source language is c.
Producer is GNU C17 11.4.0 -mlittle-endian -mabi=lp64 -g -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection.
Compiled with DWARF 5 debugging format.
Does not include preprocessor macro info.

(gdb) info sources
/home/pifan/Projects/cpp/helloc:

/home/pifan/Projects/cpp/helloc.c

```

> run/start 运行起来后，info sources 列表会多出很多运行时依赖文件和 libc.so.6。

### list

[Source (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Source.html#Source)

执行 `list` / `l` 命令打印程序的源代码（List specified function or line），可指定函数名或行号。

```Shell
(gdb) help list
list, l
List specified function or line.
With no argument, lists ten more lines after or around previous listing.
"list -" lists the ten lines before a previous ten-line listing.
One argument specifies a line, and ten lines are listed around that line.
Two arguments with comma between specify starting and ending lines to list.
Lines can be specified in these ways:
  LINENUM, to list around that line in current file,
  FILE:LINENUM, to list around that line in that file,
  FUNCTION, to list around beginning of that function,
  FILE:FUNCTION, to distinguish among like-named static functions.
  *ADDRESS, to list around the line containing that address.
With two args, if one is empty, it stands for ten lines away from
the other arg.

By default, when a single location is given, display ten lines.
This can be changed using "set listsize", and the current value
can be shown using "show listsize".
```

`list 0` 从第 1 行开始显示源程序。
`list +` 显示当前断点行后面的源程序，参数缺省行为。
`list -` 显示当前断点行前面的源程序。

*   每次显示 10 行（由 listsize 控制）。

```Shell
(gdb) list
1	#include <stdio.h>
2	
3	int main(int argc, char *argv[]) {
4	    printf("Hello world from c!\n");
5	
6	    return 0;
7	}
```

按回车键重复上一次的命令，即继续 list 显示下一个 10 行。

当显示到文件最后一行（EOF），会提示 out of range：

```Shell
(gdb)
Line number 8 out of range; helloc.c has 7 lines.
```

此时可执行 `l 0` 从头开始显示。

`list <linenum>`：显示程序第linenum行上下各 5 行源程序。
`list <function>`：显示指定名称函数的源程序。

## run / start

[4 Running Programs Under GDB](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Running.html#Running) | [4.2 Starting your Program](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Starting.html#Starting)

### run

`run` / `r`: Use the `run` command to start your program under GDB. You must first specify the program name with an argument to GDB (see [Getting In and Out of GDB](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Invocation.html#Invocation)), or by using the file or exec-file command (see [Commands to Specify Files](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Files.html#Files)).

```Shell
(gdb) help run
run, r
Start debugged program.
You may specify arguments to give it.
Args may include "*", or "[...]"; they are expanded using the
shell that will start the program (specified by the "$SHELL" environment
variable).  Input and output redirection with ">", "<", or ">>"
are also allowed.

With no arguments, uses arguments last specified (with "run" or
"set args").  To cancel previous arguments and run with no arguments,
use "set args" without arguments.

To start the inferior without using a shell, use "set startup-with-shell off".
```

执行 `gdb helloc` 启动 gdb 调试 gcc 编译好的 helloc。 或中途执行 `file` 命令加载切换新的调试目标后，即可执行 `run` 命令启动运行。 如果没有设置断点，则默认执行完整个程序。

```Shell
(gdb) r
Starting program: /home/pifan/Projects/cpp/helloc
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".
Hello world from c!
[Inferior 1 (process 145910) exited normally]
```

> When you issue the `run` command, your program begins to execute immediately. See [Stopping and Continuing](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Stopping.html#Stopping), for discussion of how to arrange for your program to stop. Once your program has stopped, you may call functions in your program, using the `print` or `call` commands. See [Examining Data](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Data.html#Data).

### start

`start`: The debugger provides a convenient way to start the execution of the program and to stop at the beginning of the `main` procedure, depending on the language used.

The ‘start’ command does the equivalent of setting a *temporary* breakpoint at the beginning of the main procedure and then invoking the ‘run’ command.

`starti`: The ‘starti’ command does the equivalent of setting a temporary breakpoint at the first instruction of a program’s execution and then invoking the ‘run’ command. For programs containing an *elaboration* phase, the starti command will stop execution at the start of the elaboration phase.

```Shell
(gdb) help start
Start the debugged program stopping at the beginning of the main procedure.
You may specify arguments to give it.
Args may include "*", or "[...]"; they are expanded using the
shell that will start the program (specified by the "$SHELL" environment
variable).  Input and output redirection with ">", "<", or ">>"
are also allowed.

With no arguments, uses arguments last specified (with "run" or
"set args").  To cancel previous arguments and run with no arguments,
use "set args" without arguments.

To start the inferior without using a shell, use "set startup-with-shell off".
```

执行 `gdb helloc` 启动 gdb 进入调试 REPL 后，输入 start 将启动运行，在入口函数 main 处的临时断点（tbreak）停下，相当于 tb main + run。

```Shell
(gdb) start
Temporary breakpoint 1 at 0x764: file helloc.c, line 4.
Starting program: /home/pifan/Projects/cpp/helloc
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".

Temporary breakpoint 1, main (argc=1, argv=0xfffffffff248) at helloc.c:4
4	    printf("Hello world from c!\n");
```

### restart

调试过程中，随时可以输入 `run` 或 `start` 从头开始执行。

```Shell
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n)

(gdb) start
The program being debugged has been started already.
Start it from the beginning? (y or n)
```

### info

执行 `info proc` 命令可查看进程信息：

```Shell
(gdb) help info proc
Show additional information about a process.

(gdb) i proc
process 147173
cmdline = '/home/pifan/Projects/cpp/helloc'
cwd = '/home/pifan/Projects/cpp'
exe = '/home/pifan/Projects/cpp/helloc'
```

> 此时，在另外一个终端窗口键入 `cat /proc/147173/maps` 可以查看系统给进程（PID 为147173）分配的虚拟地址空间。

执行 `info share` 命令可查看加载的动态库信息：

```Shell
(gdb) help info sharedlibrary
info sharedlibrary, info dll
Status of loaded shared object libraries.

(gdb) i share
From                To                  Syms Read   Shared Object Library
0x0000fffff7fc3c40  0x0000fffff7fe20a4  Yes         /lib/ld-linux-aarch64.so.1
0x0000fffff7e37040  0x0000fffff7f43090  Yes         /lib/aarch64-linux-gnu/libc.so.6
```

## Quitting

[Quitting GDB (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Quitting-GDB.html#Quitting-GDB)

*   quit \[expression]
*   exit \[expression]
*   q

To exit GDB, use the quit command (abbreviated `q`), the `exit` command, or type an end-of-file character (usually `Ctrl-d`). If you do not supply expression, GDB will terminate normally; otherwise it will terminate using the result of expression as the error code.

An interrupt (often `Ctrl-c`) does not exit from GDB, but rather terminates the action of any GDB command that is in progress and returns to GDB command level.
